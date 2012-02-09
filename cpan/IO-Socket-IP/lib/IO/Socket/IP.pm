#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2010-2012 -- leonerd@leonerd.org.uk

package IO::Socket::IP;

use strict;
use warnings;
use base qw( IO::Socket );

our $VERSION = '0.08_004';

use Carp;

use Socket 1.97 qw(
   getaddrinfo getnameinfo
   AF_INET
   AI_PASSIVE
   IPPROTO_TCP IPPROTO_UDP
   IPPROTO_IPV6 IPV6_V6ONLY
   NI_DGRAM NI_NUMERICHOST NI_NUMERICSERV NIx_NOHOST NIx_NOSERV
   SO_REUSEADDR SO_REUSEPORT SO_BROADCAST SO_ERROR
   SOCK_DGRAM SOCK_STREAM 
   SOL_SOCKET
);
my $AF_INET6 = eval { Socket::AF_INET6() }; # may not be defined
my $AI_ADDRCONFIG = eval { Socket::AI_ADDRCONFIG() } || 0;
use POSIX qw( dup2 );
use Errno qw( EINVAL EINPROGRESS );

use constant HAVE_MSWIN32 => ( $^O eq "MSWin32" );

my $IPv6_re = do {
   # translation of RFC 3986 3.2.2 ABNF to re
   my $IPv4address = do {
      my $dec_octet = q<(?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])>;
      qq<$dec_octet(?: \\. $dec_octet){3}>;
   };
   my $IPv6address = do {
      my $h16  = qq<[0-9A-Fa-f]{1,4}>;
      my $ls32 = qq<(?: $h16 : $h16 | $IPv4address)>;
      qq<(?:
                                            (?: $h16 : ){6} $ls32
         |                               :: (?: $h16 : ){5} $ls32
         | (?:                   $h16 )? :: (?: $h16 : ){4} $ls32
         | (?: (?: $h16 : ){0,1} $h16 )? :: (?: $h16 : ){3} $ls32
         | (?: (?: $h16 : ){0,2} $h16 )? :: (?: $h16 : ){2} $ls32
         | (?: (?: $h16 : ){0,3} $h16 )? ::     $h16 :      $ls32
         | (?: (?: $h16 : ){0,4} $h16 )? ::                 $ls32
         | (?: (?: $h16 : ){0,5} $h16 )? ::                 $h16
         | (?: (?: $h16 : ){0,6} $h16 )? ::
      )>
   };
   qr<$IPv6address>xo;
};

=head1 NAME

C<IO::Socket::IP> - A drop-in replacement for C<IO::Socket::INET> supporting
both IPv4 and IPv6

=head1 SYNOPSIS

 use IO::Socket::IP;

 my $sock = IO::Socket::IP->new(
    PeerHost => "www.google.com",
    PeerPort => "http",
    Type     => SOCK_STREAM,
 ) or die "Cannot construct socket - $@";

 my $familyname = ( $sock->sockdomain == PF_INET6 ) ? "IPv6" :
                  ( $sock->sockdomain == PF_INET  ) ? "IPv4" :
                                                      "unknown";

 printf "Connected to google via %s\n", $familyname;

=head1 DESCRIPTION

This module provides a protocol-independent way to use IPv4 and IPv6 sockets,
as a drop-in replacement for L<IO::Socket::INET>. Most constructor arguments
and methods are provided in a backward-compatible way. For a list of known
differences, see the C<IO::Socket::INET> INCOMPATIBILITES section below.

It uses the C<getaddrinfo(3)> function to convert hostnames and service names
or port numbers into sets of possible addresses to connect to or listen on.
This allows it to work for IPv6 where the system supports it, while still
falling back to IPv4-only on systems which don't.

=head1 REPLACING C<IO::Socket> DEFAULT BEHAVIOUR

By placing C<-register> in the import list, C<IO::Socket> uses
C<IO::Socket::IP> rather than C<IO::Socket::INET> as the class that handles
C<PF_INET>.  C<IO::Socket> will also use C<IO::Socket::IP> rather than
C<IO::Socket::INET6> to handle C<PF_INET6>, provided that the C<AF_INET6>
constant is available.

Changing C<IO::Socket>'s default behaviour means that calling the
C<IO::Socket> constructor with either C<PF_INET> or C<PF_INET6> as the
C<Domain> parameter will yield an C<IO::Socket::IP> object.

 use IO::Socket::IP -register;

 my $sock = IO::Socket->new(
    Domain    => PF_INET6,
    LocalHost => "::1",
    Listen    => 1,
 ) or die "Cannot create socket - $@\n";

 print "Created a socket of type " . ref($sock) . "\n";

Note that C<-register> is a global setting that applies to the entire program;
it cannot be applied only for certain callers, removed, or limited by lexical
scope.

=cut

sub import
{
   my $pkg = shift;
   my @symbols;

   foreach ( @_ ) {
      if( $_ eq "-register" ) {
         $pkg->register_domain( AF_INET );
         $pkg->register_domain( $AF_INET6 ) if defined $AF_INET6;
      }
      else {
         push @symbols, $_;
      }
   }
   
   @_ = ( $pkg, @symbols );
   goto &IO::Socket::import;
}

# Convenient capability test function
{
   my $can_disable_v6only;
   sub CAN_DISABLE_V6ONLY
   {
      return $can_disable_v6only if defined $can_disable_v6only;

      socket my $testsock, Socket::PF_INET6, SOCK_STREAM, 0 or
         die "Cannot socket(PF_INET6) - $!";

      if( setsockopt $testsock, IPPROTO_IPV6, IPV6_V6ONLY, 0 ) {
         return $can_disable_v6only = 1;
      }
      elsif( $! == EINVAL ) {
         return $can_disable_v6only = 0;
      }
      else {
         die "Cannot setsockopt() - $!";
      }
   }
}

=head1 CONSTRUCTORS

=cut

=head2 $sock = IO::Socket::IP->new( %args )

Creates a new C<IO::Socket::IP> object, containing a newly created socket
handle according to the named arguments passed. The recognised arguments are:

=over 8

=item PeerHost => STRING

=item PeerService => STRING

Hostname and service name for the peer to C<connect()> to. The service name
may be given as a port number, as a decimal string.

=item PeerAddr => STRING

=item PeerPort => STRING

For symmetry with the accessor methods and compatibility with
C<IO::Socket::INET>, these are accepted as synonyms for C<PeerHost> and
C<PeerService> respectively.

=item PeerAddrInfo => ARRAY

Alternate form of specifying the peer to C<connect()> to. This should be an
array of the form returned by C<Socket::getaddrinfo>.

This parameter takes precedence over the C<Peer*>, C<Family>, C<Type> and
C<Proto> arguments.

=item LocalHost => STRING

=item LocalService => STRING

Hostname and service name for the local address to C<bind()> to.

=item LocalAddr => STRING

=item LocalPort => STRING

For symmetry with the accessor methods and compatibility with
C<IO::Socket::INET>, these are accepted as synonyms for C<LocalHost> and
C<LocalService> respectively.

=item LocalAddrInfo => ARRAY

Alternate form of specifying the local address to C<bind()> to. This should be
an array of the form returned by C<Socket::getaddrinfo>.

This parameter takes precedence over the C<Local*>, C<Family>, C<Type> and
C<Proto> arguments.

=item Family => INT

The address family to pass to C<getaddrinfo> (e.g. C<AF_INET>, C<AF_INET6>).
Normally this will be left undefined, and C<getaddrinfo> will search using any
address family supported by the system.

=item Type => INT

The socket type to pass to C<getaddrinfo> (e.g. C<SOCK_STREAM>,
C<SOCK_DGRAM>). Normally defined by the caller; if left undefined
C<getaddrinfo> may attempt to infer the type from the service name.

=item Proto => STRING or INT

The IP protocol to use for the socket (e.g. C<'tcp'>, C<IPPROTO_TCP>,
C<'udp'>,C<IPPROTO_UDP>). Normally this will be left undefined, and either
C<getaddrinfo> or the kernel will choose an appropriate value. May be given
either in string name or numeric form.

=item Listen => INT

If defined, puts the socket into listening mode where new connections can be
accepted using the C<accept> method. The value given is used as the
C<listen(2)> queue size.

=item ReuseAddr => BOOL

If true, set the C<SO_REUSEADDR> sockopt

=item ReusePort => BOOL

If true, set the C<SO_REUSEPORT> sockopt (not all OSes implement this sockopt)

=item Broadcast => BOOL

If true, set the C<SO_BROADCAST> sockopt

=item V6Only => BOOL

If defined, set the C<IPV6_V6ONLY> sockopt when creating C<PF_INET6> sockets
to the given value. If true, a listening-mode socket will only listen on the
C<AF_INET6> addresses; if false it will also accept connections from
C<AF_INET> addresses.

If not defined, the socket option will not be changed, and default value set
by the operating system will apply. For repeatable behaviour across platforms
it is recommended this value always be defined for listening-mode sockets.

Note that not all platforms support disabling this option. Some, at least
OpenBSD and MirBSD, will fail with C<EINVAL> if you attempt to disable it.
To determine whether it is possible to disable, you may use the class method

 if( IO::Socket::IP->CAN_DISABLE_V6ONLY ) {
    ...
 }
 else {
    ...
 }

If your platform does not support disabling this option but you still want to
listen for both C<AF_INET> and C<AF_INET6> connections you will have to create
two listening sockets, one bound to each protocol.

=item Timeout

This C<IO::Socket::INET>-style argument is not currently supported. See the
C<IO::Socket::INET> INCOMPATIBILITES section below.

=item MultiHomed

This C<IO::Socket::INET>-style argument is ignored, except if it is defined
but false. See the C<IO::Socket::INET> INCOMPATIBILITES section below. 

However, the behaviour it enables is always performed by C<IO::Socket::IP>.

=item Blocking => BOOL

If defined but false, the socket will be set to non-blocking mode. Otherwise
it will default to blocking mode. See the NON-BLOCKING section below for more
detail.

=back

If neither C<Type> nor C<Proto> hints are provided, a default of
C<SOCK_STREAM> and C<IPPROTO_TCP> respectively will be set, to maintain
compatibility with C<IO::Socket::INET>.

If the constructor fails, it will set C<$@> to an appropriate error message;
this may be from C<$!> or it may be some other string; not every failure
necessarily has an associated C<errno> value.

=head2 $sock = IO::Socket::IP->new( $peeraddr )

As a special case, if the constructor is passed a single argument (as
opposed to an even-sized list of key/value pairs), it is taken to be the value
of the C<PeerAddr> parameter. This is parsed in the same way, according to the
behaviour given in the C<PeerHost> AND C<LocalHost> PARSING section below.

=cut

sub new 
{
   my $class = shift;
   my %arg = (@_ == 1) ? (PeerHost => $_[0]) : @_;
   return $class->SUPER::new(%arg);
}

# IO::Socket may call this one; neaten up the arguments from IO::Socket::INET
# before calling our real _configure method
sub configure
{
   my $self = shift;
   my ( $arg ) = @_;

   $arg->{PeerHost} = delete $arg->{PeerAddr}
      if exists $arg->{PeerAddr} && !exists $arg->{PeerHost};

   $arg->{PeerService} = delete $arg->{PeerPort}
      if exists $arg->{PeerPort} && !exists $arg->{PeerService};

   $arg->{LocalHost} = delete $arg->{LocalAddr}
      if exists $arg->{LocalAddr} && !exists $arg->{LocalHost};

   $arg->{LocalService} = delete $arg->{LocalPort}
      if exists $arg->{LocalPort} && !exists $arg->{LocalService};

   for my $type (qw(Peer Local)) {
      my $host    = $type . 'Host';
      my $service = $type . 'Service';

      if (exists $arg->{$host} && !exists $arg->{$service}) {
         local $_ = $arg->{$host};
         defined or next;
         local ( $1, $2 ); # Placate a taint-related bug; [perl #67962]
         if (/\A\[($IPv6_re)\](?::([^\s:]*))?\z/o || /\A([^\s:]*):([^\s:]*)\z/) {
            $arg->{$host}    = $1;
            $arg->{$service} = $2 if defined $2 && length $2;
         }
      }
   }

   $self->_configure( $arg );
}

sub _configure
{
   my $self = shift;
   my ( $arg ) = @_;

   my %hints;
   my @localinfos;
   my @peerinfos;

   $hints{flags} = $AI_ADDRCONFIG;

   # Check for definedness of args, but delete them anyway even if they're
   # not defined. Then the only remaining keys will be unrecognised ones.

   if( defined( my $family = delete $arg->{Family} ) ) {
      $hints{family} = $family;
   }

   if( defined( my $type = delete $arg->{Type} ) ) {
      $hints{socktype} = $type;
   }

   if( defined( my $proto = delete $arg->{Proto} ) ) {
      unless( $proto =~ m/^\d+$/ ) {
         my $protonum = getprotobyname( $proto );
         defined $protonum or croak "Unrecognised protocol $proto";
         $proto = $protonum;
      }

      $hints{protocol} = $proto;
   }

   # To maintain compatibilty with IO::Socket::INET, imply a default of
   # SOCK_STREAM + IPPROTO_TCP if neither hint is given
   if( !defined $hints{socktype} and !defined $hints{protocol} ) {
      $hints{socktype} = SOCK_STREAM;
      $hints{protocol} = IPPROTO_TCP;
   }

   # Some OSes (NetBSD) don't seem to like just a protocol hint without a
   # socktype hint as well. We'll set a couple of common ones
   if( !defined $hints{socktype} and defined $hints{protocol} ) {
      $hints{socktype} = SOCK_STREAM if $hints{protocol} == IPPROTO_TCP;
      $hints{socktype} = SOCK_DGRAM  if $hints{protocol} == IPPROTO_UDP;
   }

   if( my $info = delete $arg->{LocalAddrInfo} ) {
      ref $info eq "ARRAY" or croak "Expected 'LocalAddrInfo' to be an ARRAY ref";
      @localinfos = @$info;
   }
   elsif( defined $arg->{LocalHost} or defined $arg->{LocalService} ) {
      # Either may be undef
      my $host = $arg->{LocalHost};
      my $service = $arg->{LocalService};

      local $1; # Placate a taint-related bug; [perl #67962]
      defined $service and $service =~ s/\((\d+)\)$// and
         my $fallback_port = $1;

      my %localhints = %hints;
      $localhints{flags} |= AI_PASSIVE;
      ( my $err, @localinfos ) = getaddrinfo( $host, $service, \%localhints );

      if( $err and defined $fallback_port ) {
         ( $err, @localinfos ) = getaddrinfo( $host, $fallback_port, \%localhints );
      }

      $err and ( $@ = "$err", return );
   }
   delete $arg->{LocalHost};
   delete $arg->{LocalService};

   if( my $info = delete $arg->{PeerAddrInfo} ) {
      ref $info eq "ARRAY" or croak "Expected 'PeerAddrInfo' to be an ARRAY ref";
      @peerinfos = @$info;
   }
   elsif( defined $arg->{PeerHost} or defined $arg->{PeerService} ) {
      defined( my $host = delete $arg->{PeerHost} ) or
         croak "Expected 'PeerHost'";
      defined( my $service = delete $arg->{PeerService} ) or
         croak "Expected 'PeerService'";

      local $1; # Placate a taint-related bug; [perl #67962]
      defined $service and $service =~ s/\((\d+)\)$// and
         my $fallback_port = $1;

      ( my $err, @peerinfos ) = getaddrinfo( $host, $service, \%hints );

      if( $err and defined $fallback_port ) {
         ( $err, @peerinfos ) = getaddrinfo( $host, $fallback_port, \%hints );
      }

      $err and ( $@ = "$err", return );
   }
   delete $arg->{PeerHost};
   delete $arg->{PeerService};

   my @sockopts_enabled;
   push @sockopts_enabled, SO_REUSEADDR if delete $arg->{ReuseAddr};
   push @sockopts_enabled, SO_REUSEPORT if delete $arg->{ReusePort};
   push @sockopts_enabled, SO_BROADCAST if delete $arg->{Broadcast};

   my $listenqueue = delete $arg->{Listen};

   croak "Cannot Listen with a PeerHost" if defined $listenqueue and @peerinfos;

   my $blocking = delete $arg->{Blocking};
   defined $blocking or $blocking = 1;

   my $v6only = delete $arg->{V6Only};

   # IO::Socket::INET defines this key. IO::Socket::IP always implements the
   # behaviour it requests, so we can ignore it, unless the caller is for some
   # reason asking to disable it.
   if( defined $arg->{MultiHomed} and !$arg->{MultiHomed} ) {
      croak "Cannot disable the MultiHomed parameter";
   }
   delete $arg->{MultiHomed};

   keys %$arg and croak "Unexpected keys - " . join( ", ", sort keys %$arg );

   my @infos;
   foreach my $local ( @localinfos ? @localinfos : {} ) {
      foreach my $peer ( @peerinfos ? @peerinfos : {} ) {
         next if defined $local->{family}   and defined $peer->{family}   and
            $local->{family} != $peer->{family};
         next if defined $local->{socktype} and defined $peer->{socktype} and
            $local->{socktype} != $peer->{socktype};
         next if defined $local->{protocol} and defined $peer->{protocol} and
            $local->{protocol} != $peer->{protocol};

         my $family   = $local->{family}   || $peer->{family}   or next;
         my $socktype = $local->{socktype} || $peer->{socktype} or next;
         my $protocol = $local->{protocol} || $peer->{protocol} || 0;

         push @infos, {
            family    => $family,
            socktype  => $socktype,
            protocol  => $protocol,
            localaddr => $local->{addr},
            peeraddr  => $peer->{addr},
         };
      }
   }

   # In the nonblocking case, caller will be calling ->setup multiple times.
   # Store configuration in the object for the ->setup method
   # Yes, these are messy. Sorry, I can't help that...

   ${*$self}{io_socket_ip_infos} = \@infos;

   ${*$self}{io_socket_ip_idx} = -1;

   ${*$self}{io_socket_ip_sockopts} = \@sockopts_enabled;
   ${*$self}{io_socket_ip_v6only} = $v6only;
   ${*$self}{io_socket_ip_listenqueue} = $listenqueue;
   ${*$self}{io_socket_ip_blocking} = $blocking;

   ${*$self}{io_socket_ip_errors} = [ undef, undef, undef ];

   if( $blocking ) {
      $self->setup or return undef;
   }
   return $self;
}

sub setup
{
   my $self = shift;

   while(1) {
      ${*$self}{io_socket_ip_idx}++;
      last if ${*$self}{io_socket_ip_idx} >= @{ ${*$self}{io_socket_ip_infos} };

      my $info = ${*$self}{io_socket_ip_infos}->[${*$self}{io_socket_ip_idx}];

      $self->socket( @{$info}{qw( family socktype protocol )} ) or
         ( ${*$self}{io_socket_ip_errors}[2] = $!, next );

      $self->blocking( 0 ) unless ${*$self}{io_socket_ip_blocking};

      foreach my $sockopt ( @{ ${*$self}{io_socket_ip_sockopts} } ) {
         $self->setsockopt( SOL_SOCKET, $sockopt, pack "i", 1 ) or ( $@ = "$!", return undef );
      }

      if( defined ${*$self}{io_socket_ip_v6only} and defined $AF_INET6 and $info->{family} == $AF_INET6 ) {
         my $v6only = ${*$self}{io_socket_ip_v6only};
         $self->setsockopt( IPPROTO_IPV6, IPV6_V6ONLY, pack "i", $v6only ) or ( $@ = "$!", return undef );
      }

      if( defined( my $addr = $info->{localaddr} ) ) {
         $self->bind( $addr ) or
            ( ${*$self}{io_socket_ip_errors}[1] = $!, next );
      }

      if( defined( my $listenqueue = ${*$self}{io_socket_ip_listenqueue} ) ) {
         $self->listen( $listenqueue ) or ( $@ = "$!", return undef );
      }

      if( defined( my $addr = $info->{peeraddr} ) ) {
         # It seems that IO::Socket hides EINPROGRESS errors, making them look
         # like a success. This is annoying here.
         # Instead of putting up with its frankly-irritating intentional
         # breakage of useful APIs I'm just going to end-run around it and
         # call CORE::connect() directly
         if( CORE::connect( $self, $addr ) ) {
            $! = 0;
            return 1;
         }

         return 0 if $! == EINPROGRESS or HAVE_MSWIN32 && $! == Errno::EWOULDBLOCK();

         ${*$self}{io_socket_ip_errors}[0] = $!;
         next;
      }

      return 1;
   }

   $self->close;

   # Pick the most appropriate error, stringified
   $! = ( grep defined, @{ ${*$self}{io_socket_ip_errors}} )[0];
   $@ = "$!";
   return undef;
}

sub connect
{
   my $self = shift;
   return $self->SUPER::connect( @_ ) if @_;

   $! = 0, return 1 if $self->fileno and defined $self->peername;

   if( $self->fileno ) {
      # A connect has just failed, get its error value
      ${*$self}{io_socket_ip_errors}[0] = $self->getsockopt( SOL_SOCKET, SO_ERROR );
   }

   return $self->setup;
}

=head1 METHODS

As well as the following methods, this class inherits all the methods in
L<IO::Socket> and L<IO::Handle>.

=cut

sub _get_host_service
{
   my $self = shift;
   my ( $addr, $flags, $xflags ) = @_;

   $flags |= NI_DGRAM if $self->socktype == SOCK_DGRAM;

   my ( $err, $host, $service ) = getnameinfo( $addr, $flags, $xflags || 0 );
   croak "getnameinfo - $err" if $err;

   return ( $host, $service );
}

=head2 ( $host, $service ) = $sock->sockhost_service( $numeric )

Returns the hostname and service name of the local address (that is, the
socket address given by the C<sockname> method).

If C<$numeric> is true, these will be given in numeric form rather than being
resolved into names.

The following four convenience wrappers may be used to obtain one of the two
values returned here. If both host and service names are required, this method
is preferable to the following wrappers, because it will call
C<getnameinfo(3)> only once.

=cut

sub sockhost_service
{
   my $self = shift;
   my ( $numeric ) = @_;

   $self->_get_host_service( $self->sockname, $numeric ? NI_NUMERICHOST|NI_NUMERICSERV : 0 );
}

=head2 $addr = $sock->sockhost

Return the numeric form of the local address

=head2 $port = $sock->sockport

Return the numeric form of the local port number

=head2 $host = $sock->sockhostname

Return the resolved name of the local address

=head2 $service = $sock->sockservice

Return the resolved name of the local port number

=cut

sub sockhost { my $self = shift; ( $self->_get_host_service( $self->sockname, NI_NUMERICHOST, NIx_NOSERV ) )[0] }
sub sockport { my $self = shift; ( $self->_get_host_service( $self->sockname, NI_NUMERICSERV, NIx_NOHOST ) )[1] }

sub sockhostname { my $self = shift; ( $self->_get_host_service( $self->sockname, 0, NIx_NOSERV ) )[0] }
sub sockservice  { my $self = shift; ( $self->_get_host_service( $self->sockname, 0, NIx_NOHOST ) )[1] }

=head2 ( $host, $service ) = $sock->peerhost_service( $numeric )

Returns the hostname and service name of the peer address (that is, the
socket address given by the C<peername> method), similar to the
C<sockhost_service> method.

The following four convenience wrappers may be used to obtain one of the two
values returned here. If both host and service names are required, this method
is preferable to the following wrappers, because it will call
C<getnameinfo(3)> only once.

=cut

sub peerhost_service
{
   my $self = shift;
   my ( $numeric ) = @_;

   $self->_get_host_service( $self->peername, $numeric ? NI_NUMERICHOST|NI_NUMERICSERV : 0 );
}

=head2 $addr = $sock->peerhost

Return the numeric form of the peer address

=head2 $port = $sock->peerport

Return the numeric form of the peer port number

=head2 $host = $sock->peerhostname

Return the resolved name of the peer address

=head2 $service = $sock->peerservice

Return the resolved name of the peer port number

=cut

sub peerhost { my $self = shift; ( $self->_get_host_service( $self->peername, NI_NUMERICHOST, NIx_NOSERV ) )[0] }
sub peerport { my $self = shift; ( $self->_get_host_service( $self->peername, NI_NUMERICSERV, NIx_NOHOST ) )[1] }

sub peerhostname { my $self = shift; ( $self->_get_host_service( $self->peername, 0, NIx_NOSERV ) )[0] }
sub peerservice  { my $self = shift; ( $self->_get_host_service( $self->peername, 0, NIx_NOHOST ) )[1] }

# This unbelievably dodgy hack works around the bug that IO::Socket doesn't do
# it
#    https://rt.cpan.org/Ticket/Display.html?id=61577
sub accept
{
   my $self = shift;
   my ( $new, $peer ) = $self->SUPER::accept or return;

   ${*$new}{$_} = ${*$self}{$_} for qw( io_socket_domain io_socket_type io_socket_proto );

   return wantarray ? ( $new, $peer )
                    : $new;
}

# This second unbelievably dodgy hack guarantees that $self->fileno doesn't
# change, which is useful during nonblocking connect
sub socket
{
   my $self = shift;
   return $self->SUPER::socket(@_) if not defined $self->fileno;

   # I hate core prototypes sometimes...
   CORE::socket( my $tmph, $_[0], $_[1], $_[2] ) or return undef;

   dup2( $tmph->fileno, $self->fileno ) or die "Unable to dup2 $tmph onto $self - $!";
}

=head1 NON-BLOCKING

If the constructor is passed a defined but false value for the C<Blocking>
argument then the socket is put into non-blocking mode. When in non-blocking
mode, the socket will not be set up by the time the constructor returns,
because the underlying C<connect(2)> syscall would otherwise have to block.

The non-blocking behaviour is an extension of the C<IO::Socket::INET> API,
unique to C<IO::Socket::IP>, because the former does not support multi-homed
non-blocking connect.

When using non-blocking mode, the caller must repeatedly check for
writeability on the filehandle (for instance using C<select> or C<IO::Poll>).
Each time the filehandle is ready to write, the C<connect> method must be
called, with no arguments. Note that some operating systems, most notably
C<MSWin32> do not report a C<connect()> failure using write-ready; so you must
also C<select()> for exceptional status.

While C<connect> returns false, the value of C<$!> indicates whether it should
be tried again (by being set to the value C<EINPROGRESS>, or C<EWOULDBLOCK> on
MSWin32), or whether a permanent error has occurred (e.g. C<ECONNREFUSED>).

Once the socket has been connected to the peer, C<connect> will return true
and the socket will now be ready to use.

Note that calls to the platform's underlying C<getaddrinfo(3)> function may
block. If C<IO::Socket::IP> has to perform this lookup, the constructor will
block even when in non-blocking mode.

To avoid this blocking behaviour, the caller should pass in the result of such
a lookup using the C<PeerAddrInfo> or C<LocalAddrInfo> arguments. This can be
achieved by using L<Net::LibAsyncNS>, or the C<getaddrinfo(3)> function can be
called in a child process.

 use IO::Socket::IP;
 use Errno qw( EINPROGRESS EWOULDBLOCK );

 my @peeraddrinfo = ... # Caller must obtain the getaddinfo result here

 my $socket = IO::Socket::IP->new(
    PeerAddrInfo => \@peeraddrinfo,
    Blocking     => 0,
 ) or die "Cannot construct socket - $@";

 while( !$socket->connect and ( $! == EINPROGRESS || $! == EWOULDBLOCK ) ) {
    my $wvec = '';
    vec( $wvec, fileno $socket, 1 ) = 1;
    my $evec = '';
    vec( $evec, fileno $socket, 1 ) = 1;

    select( undef, $wvec, $evec, undef ) or die "Cannot select - $!";
 }

 die "Cannot connect - $!" if $!;

 ...

The example above uses C<select()>, but any similar mechanism should work
analogously. C<IO::Socket::IP> takes care when creating new socket filehandles
to preserve the actual file descriptor number, so such techniques as C<poll>
or C<epoll> should be transparent to its reallocation of a different socket
underneath, perhaps in order to switch protocol family between C<PF_INET> and
C<PF_INET6>.

For another example using C<IO::Poll> and C<Net::LibAsyncNS>, see the
F<examples/nonblocking_libasyncns.pl> file in the module distribution.

=head1 C<PeerHost> AND C<LocalHost> PARSING

To support the C<IO::Socket::INET> API, the host and port information may be
passed in a single string rather than as two separate arguments.

If either C<LocalHost> or C<PeerHost> (or their C<...Addr> synonyms) have any
of the following special forms, and C<LocalService> or C<PeerService> (or
their C<...Port> synonyms) are absent, special parsing is applied.

The value of the C<...Host> argument will be split to give both the hostname
and port (or service name):

 hostname.example.org:http    # Host name
 192.0.2.1:80                 # IPv4 address
 [2001:db8::1]:80             # IPv6 address

In each case, the port or service name (e.g. C<80>) is passed as the
C<LocalService> or C<PeerService> argument.

Either of C<LocalService> or C<PeerService> (or their C<...Port> synonyms) can
be either a service name, a decimal number, or a string containing both a
service name and number, in a form such as

 http(80)

In this case, the name (C<http>) will be tried first, but if the resolver does
not understand it then the port number (C<80>) will be used instead.

=head1 C<IO::Socket::INET> INCOMPATIBILITES

=over 4

=item *

The C<Timeout> constructor argument is currently not recognised.

The behaviour enabled by C<MultiHomed> is in fact implemented by
C<IO::Socket::IP> as it is required to correctly support searching for a
useable address from the results of the C<getaddrinfo(3)> call. The
constructor will ignore the value of this argument, except if it is defined
but false. An exception is thrown in this case, because that would request it
disable the C<getaddrinfo(3)> search behaviour in the first place.

=back

=cut

=head1 TODO

=over 4

=item *

Investigate whether C<POSIX::dup2> upsets BSD's C<kqueue> watchers, and if so,
consider what possible workarounds might be applied.

=back

=head1 AUTHOR

Paul Evans <leonerd@leonerd.org.uk>

=cut

0x55AA;