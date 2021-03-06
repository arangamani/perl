#!perl -w
BEGIN {
    if (ord("A") != 65) {
	print "1..0 # Skip: EBCDIC\n";
	exit 0;
    }
    chdir 't' if -d 't';
    @INC = '../lib';
    require Config; import Config;
    if ($Config{'extensions'} !~ /\bStorable\b/) {
        print "1..0 # Skip: Storable was not built; Unicode::UCD uses Storable\n";
        exit 0;
    }
}

use strict;
use Unicode::UCD;
use Test::More;

use Unicode::UCD 'charinfo';

$/ = 7;

my $charinfo;

is(charinfo(0x110000), undef, "Verify charinfo() of non-unicode is undef");

$charinfo = charinfo(0);    # Null is often problematic, so test it.

is($charinfo->{code},           '0000', '<control>');
is($charinfo->{name},           '<control>');
is($charinfo->{category},       'Cc');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'BN');
is($charinfo->{decomposition},  '');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      'NULL');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '');
is($charinfo->{title},          '');
is($charinfo->{block},          'Basic Latin');
is($charinfo->{script},         'Common');

$charinfo = charinfo(0x41);

is($charinfo->{code},           '0041', 'LATIN CAPITAL LETTER A');
is($charinfo->{name},           'LATIN CAPITAL LETTER A');
is($charinfo->{category},       'Lu');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  '');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      '');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '0061');
is($charinfo->{title},          '');
is($charinfo->{block},          'Basic Latin');
is($charinfo->{script},         'Latin');

$charinfo = charinfo(0x100);

is($charinfo->{code},           '0100', 'LATIN CAPITAL LETTER A WITH MACRON');
is($charinfo->{name},           'LATIN CAPITAL LETTER A WITH MACRON');
is($charinfo->{category},       'Lu');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  '0041 0304');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      'LATIN CAPITAL LETTER A MACRON');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '0101');
is($charinfo->{title},          '');
is($charinfo->{block},          'Latin Extended-A');
is($charinfo->{script},         'Latin');

# 0x0590 is in the Hebrew block but unused.

$charinfo = charinfo(0x590);

is($charinfo->{code},          undef,	'0x0590 - unused Hebrew');
is($charinfo->{name},          undef);
is($charinfo->{category},      undef);
is($charinfo->{combining},     undef);
is($charinfo->{bidi},          undef);
is($charinfo->{decomposition}, undef);
is($charinfo->{decimal},       undef);
is($charinfo->{digit},         undef);
is($charinfo->{numeric},       undef);
is($charinfo->{mirrored},      undef);
is($charinfo->{unicode10},     undef);
is($charinfo->{comment},       undef);
is($charinfo->{upper},         undef);
is($charinfo->{lower},         undef);
is($charinfo->{title},         undef);
is($charinfo->{block},         undef);
is($charinfo->{script},        undef);

# 0x05d0 is in the Hebrew block and used.

$charinfo = charinfo(0x5d0);

is($charinfo->{code},           '05D0', '05D0 - used Hebrew');
is($charinfo->{name},           'HEBREW LETTER ALEF');
is($charinfo->{category},       'Lo');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'R');
is($charinfo->{decomposition},  '');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      '');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '');
is($charinfo->{title},          '');
is($charinfo->{block},          'Hebrew');
is($charinfo->{script},         'Hebrew');

# An open syllable in Hangul.

$charinfo = charinfo(0xAC00);

is($charinfo->{code},           'AC00', 'HANGUL SYLLABLE U+AC00');
is($charinfo->{name},           'HANGUL SYLLABLE GA');
is($charinfo->{category},       'Lo');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  '1100 1161');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      '');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '');
is($charinfo->{title},          '');
is($charinfo->{block},          'Hangul Syllables');
is($charinfo->{script},         'Hangul');

# A closed syllable in Hangul.

$charinfo = charinfo(0xAE00);

is($charinfo->{code},           'AE00', 'HANGUL SYLLABLE U+AE00');
is($charinfo->{name},           'HANGUL SYLLABLE GEUL');
is($charinfo->{category},       'Lo');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  "1100 1173 11AF");
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      '');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '');
is($charinfo->{title},          '');
is($charinfo->{block},          'Hangul Syllables');
is($charinfo->{script},         'Hangul');

$charinfo = charinfo(0x1D400);

is($charinfo->{code},           '1D400', 'MATHEMATICAL BOLD CAPITAL A');
is($charinfo->{name},           'MATHEMATICAL BOLD CAPITAL A');
is($charinfo->{category},       'Lu');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  '<font> 0041');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      '');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '');
is($charinfo->{title},          '');
is($charinfo->{block},          'Mathematical Alphanumeric Symbols');
is($charinfo->{script},         'Common');

$charinfo = charinfo(0x9FBA);	#Bug 58428

is($charinfo->{code},           '9FBA', 'U+9FBA');
is($charinfo->{name},           'CJK UNIFIED IDEOGRAPH-9FBA');
is($charinfo->{category},       'Lo');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  '');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      '');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '');
is($charinfo->{title},          '');
is($charinfo->{block},          'CJK Unified Ideographs');
is($charinfo->{script},         'Han');

use Unicode::UCD qw(charblock charscript);

# 0x0590 is in the Hebrew block but unused.

is(charblock(0x590),          'Hebrew', '0x0590 - Hebrew unused charblock');
is(charscript(0x590),         'Unknown',    '0x0590 - Hebrew unused charscript');
is(charblock(0x1FFFF),        'No_Block', '0x1FFFF - unused charblock');

$charinfo = charinfo(0xbe);

is($charinfo->{code},           '00BE', 'VULGAR FRACTION THREE QUARTERS');
is($charinfo->{name},           'VULGAR FRACTION THREE QUARTERS');
is($charinfo->{category},       'No');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'ON');
is($charinfo->{decomposition},  '<fraction> 0033 2044 0034');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '3/4');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      'FRACTION THREE QUARTERS');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '');
is($charinfo->{title},          '');
is($charinfo->{block},          'Latin-1 Supplement');
is($charinfo->{script},         'Common');

# This is to test a case where both simple and full lowercases exist and
# differ
$charinfo = charinfo(0x130);

is($charinfo->{code},           '0130', 'LATIN CAPITAL LETTER I WITH DOT ABOVE');
is($charinfo->{name},           'LATIN CAPITAL LETTER I WITH DOT ABOVE');
is($charinfo->{category},       'Lu');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  '0049 0307');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      'LATIN CAPITAL LETTER I DOT');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '');
is($charinfo->{lower},          '0069');
is($charinfo->{title},          '');
is($charinfo->{block},          'Latin Extended-A');
is($charinfo->{script},         'Latin');

# This is to test a case where both simple and full uppercases exist and
# differ
$charinfo = charinfo(0x1F80);

is($charinfo->{code},           '1F80', 'GREEK SMALL LETTER ALPHA WITH PSILI AND YPOGEGRAMMENI');
is($charinfo->{name},           'GREEK SMALL LETTER ALPHA WITH PSILI AND YPOGEGRAMMENI');
is($charinfo->{category},       'Ll');
is($charinfo->{combining},      '0');
is($charinfo->{bidi},           'L');
is($charinfo->{decomposition},  '1F00 0345');
is($charinfo->{decimal},        '');
is($charinfo->{digit},          '');
is($charinfo->{numeric},        '');
is($charinfo->{mirrored},       'N');
is($charinfo->{unicode10},      '');
is($charinfo->{comment},        '');
is($charinfo->{upper},          '1F88');
is($charinfo->{lower},          '');
is($charinfo->{title},          '1F88');
is($charinfo->{block},          'Greek Extended');
is($charinfo->{script},         'Greek');

use Unicode::UCD qw(charblocks charscripts);

my $charblocks = charblocks();

ok(exists $charblocks->{Thai}, 'Thai charblock exists');
is($charblocks->{Thai}->[0]->[0], hex('0e00'));
ok(!exists $charblocks->{PigLatin}, 'PigLatin charblock does not exist');

my $charscripts = charscripts();

ok(exists $charscripts->{Armenian}, 'Armenian charscript exists');
is($charscripts->{Armenian}->[0]->[0], hex('0531'));
ok(!exists $charscripts->{PigLatin}, 'PigLatin charscript does not exist');

my $charscript;

$charscript = charscript("12ab");
is($charscript, 'Ethiopic', 'Ethiopic charscript');

$charscript = charscript("0x12ab");
is($charscript, 'Ethiopic');

$charscript = charscript("U+12ab");
is($charscript, 'Ethiopic');

my $ranges;

$ranges = charscript('Ogham');
is($ranges->[0]->[0], hex('1680'), 'Ogham charscript');
is($ranges->[0]->[1], hex('169C'));

use Unicode::UCD qw(charinrange);

$ranges = charscript('Cherokee');
ok(!charinrange($ranges, "139f"), 'Cherokee charscript');
ok( charinrange($ranges, "13a0"));
ok( charinrange($ranges, "13f4"));
ok(!charinrange($ranges, "13f5"));

use Unicode::UCD qw(general_categories);

my $gc = general_categories();

ok(exists $gc->{L}, 'has L');
is($gc->{L}, 'Letter', 'L is Letter');
is($gc->{Lu}, 'UppercaseLetter', 'Lu is UppercaseLetter');

use Unicode::UCD qw(bidi_types);

my $bt = bidi_types();

ok(exists $bt->{L}, 'has L');
is($bt->{L}, 'Left-to-Right', 'L is Left-to-Right');
is($bt->{AL}, 'Right-to-Left Arabic', 'AL is Right-to-Left Arabic');

# If this fails, then maybe one should look at the Unicode changes to see
# what else might need to be updated.
is(Unicode::UCD::UnicodeVersion, '6.0.0', 'UnicodeVersion');

use Unicode::UCD qw(compexcl);

ok(!compexcl(0x0100), 'compexcl');
ok(!compexcl(0xD801), 'compexcl of surrogate');
ok(!compexcl(0x110000), 'compexcl of non-Unicode code point');
ok( compexcl(0x0958));

use Unicode::UCD qw(casefold);

my $casefold;

$casefold = casefold(0x41);

is($casefold->{code}, '0041', 'casefold 0x41 code');
is($casefold->{status}, 'C', 'casefold 0x41 status');
is($casefold->{mapping}, '0061', 'casefold 0x41 mapping');
is($casefold->{full}, '0061', 'casefold 0x41 full');
is($casefold->{simple}, '0061', 'casefold 0x41 simple');
is($casefold->{turkic}, "", 'casefold 0x41 turkic');

$casefold = casefold(0xdf);

is($casefold->{code}, '00DF', 'casefold 0xDF code');
is($casefold->{status}, 'F', 'casefold 0xDF status');
is($casefold->{mapping}, '0073 0073', 'casefold 0xDF mapping');
is($casefold->{full}, '0073 0073', 'casefold 0xDF full');
is($casefold->{simple}, "", 'casefold 0xDF simple');
is($casefold->{turkic}, "", 'casefold 0xDF turkic');

# Do different tests depending on if version <= 3.1, or not.
(my $version = Unicode::UCD::UnicodeVersion) =~ /^(\d+)\.(\d+)/;
if (defined $1 && ($1 <= 2 || $1 == 3 && defined $2 && $2 <= 1)) {
	$casefold = casefold(0x130);

	is($casefold->{code}, '0130', 'casefold 0x130 code');
	is($casefold->{status}, 'I' , 'casefold 0x130 status');
	is($casefold->{mapping}, '0069', 'casefold 0x130 mapping');
	is($casefold->{full}, '0069', 'casefold 0x130 full');
	is($casefold->{simple}, "0069", 'casefold 0x130 simple');
	is($casefold->{turkic}, "0069", 'casefold 0x130 turkic');

	$casefold = casefold(0x131);

	is($casefold->{code}, '0131', 'casefold 0x131 code');
	is($casefold->{status}, 'I' , 'casefold 0x131 status');
	is($casefold->{mapping}, '0069', 'casefold 0x131 mapping');
	is($casefold->{full}, '0069', 'casefold 0x131 full');
	is($casefold->{simple}, "0069", 'casefold 0x131 simple');
	is($casefold->{turkic}, "0069", 'casefold 0x131 turkic');
} else {
	$casefold = casefold(0x49);

	is($casefold->{code}, '0049', 'casefold 0x49 code');
	is($casefold->{status}, 'C' , 'casefold 0x49 status');
	is($casefold->{mapping}, '0069', 'casefold 0x49 mapping');
	is($casefold->{full}, '0069', 'casefold 0x49 full');
	is($casefold->{simple}, "0069", 'casefold 0x49 simple');
	is($casefold->{turkic}, "0131", 'casefold 0x49 turkic');

	$casefold = casefold(0x130);

	is($casefold->{code}, '0130', 'casefold 0x130 code');
	is($casefold->{status}, 'F' , 'casefold 0x130 status');
	is($casefold->{mapping}, '0069 0307', 'casefold 0x130 mapping');
	is($casefold->{full}, '0069 0307', 'casefold 0x130 full');
	is($casefold->{simple}, "", 'casefold 0x130 simple');
	is($casefold->{turkic}, "0069", 'casefold 0x130 turkic');
}

$casefold = casefold(0x1F88);

is($casefold->{code}, '1F88', 'casefold 0x1F88 code');
is($casefold->{status}, 'S' , 'casefold 0x1F88 status');
is($casefold->{mapping}, '1F80', 'casefold 0x1F88 mapping');
is($casefold->{full}, '1F00 03B9', 'casefold 0x1F88 full');
is($casefold->{simple}, '1F80', 'casefold 0x1F88 simple');
is($casefold->{turkic}, "", 'casefold 0x1F88 turkic');

ok(!casefold(0x20));

use Unicode::UCD qw(casespec);

my $casespec;

ok(!casespec(0x41));

$casespec = casespec(0xdf);

ok($casespec->{code} eq '00DF' &&
   $casespec->{lower} eq '00DF'  &&
   $casespec->{title} eq '0053 0073'  &&
   $casespec->{upper} eq '0053 0053' &&
   !defined $casespec->{condition}, 'casespec 0xDF');

$casespec = casespec(0x307);

ok($casespec->{az}->{code} eq '0307' &&
   !defined $casespec->{az}->{lower} &&
   $casespec->{az}->{title} eq '0307'  &&
   $casespec->{az}->{upper} eq '0307' &&
   $casespec->{az}->{condition} eq 'az After_I',
   'casespec 0x307');

# perl #7305 UnicodeCD::compexcl is weird

for (1) {my $a=compexcl $_}
ok(1, 'compexcl read-only $_: perl #7305');
map {compexcl $_} %{{1=>2}};
ok(1, 'compexcl read-only hash: perl #7305');

is(Unicode::UCD::_getcode('123'),     123, "_getcode(123)");
is(Unicode::UCD::_getcode('0123'),  0x123, "_getcode(0123)");
is(Unicode::UCD::_getcode('0x123'), 0x123, "_getcode(0x123)");
is(Unicode::UCD::_getcode('0X123'), 0x123, "_getcode(0X123)");
is(Unicode::UCD::_getcode('U+123'), 0x123, "_getcode(U+123)");
is(Unicode::UCD::_getcode('u+123'), 0x123, "_getcode(u+123)");
is(Unicode::UCD::_getcode('U+1234'),   0x1234, "_getcode(U+1234)");
is(Unicode::UCD::_getcode('U+12345'), 0x12345, "_getcode(U+12345)");
is(Unicode::UCD::_getcode('123x'),    undef, "_getcode(123x)");
is(Unicode::UCD::_getcode('x123'),    undef, "_getcode(x123)");
is(Unicode::UCD::_getcode('0x123x'),  undef, "_getcode(x123)");
is(Unicode::UCD::_getcode('U+123x'),  undef, "_getcode(x123)");

{
    my $r1 = charscript('Latin');
    my $n1 = @$r1;
    is($n1, 30, "number of ranges in Latin script (Unicode 6.0.0)");
    shift @$r1 while @$r1;
    my $r2 = charscript('Latin');
    is(@$r2, $n1, "modifying results should not mess up internal caches");
}

{
	is(charinfo(0xdeadbeef), undef, "[perl #23273] warnings in Unicode::UCD");
}

use Unicode::UCD qw(namedseq);

is(namedseq("KATAKANA LETTER AINU P"), "\x{31F7}\x{309A}", "namedseq");
is(namedseq("KATAKANA LETTER AINU Q"), undef);
is(namedseq(), undef);
is(namedseq(qw(foo bar)), undef);
my @ns = namedseq("KATAKANA LETTER AINU P");
is(scalar @ns, 2);
is($ns[0], 0x31F7);
is($ns[1], 0x309A);
my %ns = namedseq();
is($ns{"KATAKANA LETTER AINU P"}, "\x{31F7}\x{309A}");
@ns = namedseq(42);
is(@ns, 0);

use Unicode::UCD qw(num);
use charnames ":full";

is(num("0"), 0, 'Verify num("0") == 0');
is(num("98765"), 98765, 'Verify num("98765") == 98765');
ok(! defined num("98765\N{FULLWIDTH DIGIT FOUR}"), 'Verify num("98765\N{FULLWIDTH DIGIT FOUR}") isnt defined');
is(num("\N{NEW TAI LUE DIGIT TWO}\N{NEW TAI LUE DIGIT ONE}"), 21, 'Verify num("\N{NEW TAI LUE DIGIT TWO}\N{NEW TAI LUE DIGIT ONE}") == 21');
ok(! defined num("\N{NEW TAI LUE DIGIT TWO}\N{NEW TAI LUE THAM DIGIT ONE}"), 'Verify num("\N{NEW TAI LUE DIGIT TWO}\N{NEW TAI LUE THAM DIGIT ONE}") isnt defined');
is(num("\N{CHAM DIGIT ZERO}\N{CHAM DIGIT THREE}"), 3, 'Verify num("\N{CHAM DIGIT ZERO}\N{CHAM DIGIT THREE}") == 3');
ok(! defined num("\N{CHAM DIGIT ZERO}\N{JAVANESE DIGIT NINE}"), 'Verify num("\N{CHAM DIGIT ZERO}\N{JAVANESE DIGIT NINE}") isnt defined');
is(num("\N{SUPERSCRIPT TWO}"), 2, 'Verify num("\N{SUPERSCRIPT TWO} == 2');
is(num("\N{ETHIOPIC NUMBER TEN THOUSAND}"), 10000, 'Verify num("\N{ETHIOPIC NUMBER TEN THOUSAND}") == 10000');
is(num("\N{NORTH INDIC FRACTION ONE HALF}"), .5, 'Verify num("\N{NORTH INDIC FRACTION ONE HALF}") == .5');
is(num("\N{U+12448}"), 9, 'Verify num("\N{U+12448}") == 9');

# Create a user-defined property
sub InKana {<<'END'}
3040    309F
30A0    30FF
END

use Unicode::UCD qw(prop_aliases);

is(prop_aliases(undef), undef, "prop_aliases(undef) returns <undef>");
is(prop_aliases("unknown property"), undef,
                "prop_aliases(<unknown property>) returns <undef>");
is(prop_aliases("InKana"), undef,
                "prop_aliases(<user-defined property>) returns <undef>");
is(prop_aliases("Perl_Decomposition_Mapping"), undef, "prop_aliases('Perl_Decomposition_Mapping') returns <undef> since internal-Perl-only");
is(prop_aliases("Perl_Charnames"), undef,
    "prop_aliases('Perl_Charnames') returns <undef> since internal-Perl-only");
is(prop_aliases("isgc"), undef,
    "prop_aliases('isgc') returns <undef> since is not covered Perl extension");
is(prop_aliases("Is_Is_Any"), undef,
                "prop_aliases('Is_Is_Any') returns <undef> since two is's");

require 'utf8_heavy.pl';
require "unicore/Heavy.pl";

# Keys are lists of properties. Values are defined if have been tested.
my %props;

# To test for loose matching, add in the characters that are ignored there.
my $extra_chars = "-_ ";

# The one internal property we accept
$props{'Perl_Decimal_Digit'} = 1;
my @list = prop_aliases("perldecimaldigit");
is_deeply(\@list,
          [ "Perl_Decimal_Digit",
            "Perl_Decimal_Digit"
          ], "prop_aliases('perldecimaldigit') returns Perl_Decimal_Digit as both short and full names");

# Get the official Unicode property name synonyms and test them.
open my $props, "<", "../lib/unicore/PropertyAliases.txt"
                or die "Can't open Unicode PropertyAliases.txt";
$/ = "\n";
while (<$props>) {
    s/\s*#.*//;           # Remove comments
    next if /^\s* $/x;    # Ignore empty and comment lines

    chomp;
    my $count = 0;  # 0th field in line is short name; 1th is long name
    my $short_name;
    my $full_name;
    my @names_via_short;
    foreach my $alias (split /\s*;\s*/) {    # Fields are separated by
                                             # semi-colons
        # Add in the characters that are supposed to be ignored, to test loose
        # matching, which the tested function does on all inputs.
        my $mod_name = "$extra_chars$alias";

        my $loose = &utf8::_loose_name(lc $alias);

        # Indicate we have tested this.
        $props{$loose} = 1;

        my @all_names = prop_aliases($mod_name);
        if (grep { $_ eq $loose } @Unicode::UCD::suppressed_properties) {
            is(@all_names, 0, "prop_aliases('$mod_name') returns undef since $alias is not installed");
            next;
        }
        elsif (! @all_names) {
            fail("prop_aliases('$mod_name')");
            diag("'$alias' is unknown to prop_aliases()");
            next;
        }

        if ($count == 0) {  # Is short name

            @names_via_short = prop_aliases($mod_name);

            # If the 0th test fails, no sense in continuing with the others
            last unless is($names_via_short[0], $alias,
                    "prop_aliases: '$alias' is the short name for '$mod_name'");
            $short_name = $alias;
        }
        elsif ($count == 1) {   # Is full name

            # Some properties have the same short and full name; no sense
            # repeating the test if the same.
            if ($alias ne $short_name) {
                my @names_via_full = prop_aliases($mod_name);
                is_deeply(\@names_via_full, \@names_via_short, "prop_aliases() returns the same list for both '$short_name' and '$mod_name'");
            }

            # Tests scalar context
            is(prop_aliases($short_name), $alias,
                "prop_aliases: '$alias' is the long name for '$short_name'");
        }
        else {  # Is another alias
            is_deeply(\@all_names, \@names_via_short, "prop_aliases() returns the same list for both '$short_name' and '$mod_name'");
            ok((grep { $_ =~ /^$alias$/i } @all_names),
                "prop_aliases: '$alias' is listed as an alias for '$mod_name'");
        }

        $count++;
    }
}

# Now test anything we can find that wasn't covered by the tests of the
# official properties.  We have no way of knowing if mktables omitted a Perl
# extension or not, but we do the best we can from its generated lists

foreach my $alias (keys %utf8::loose_to_file_of) {
    next if $alias =~ /=/;
    my $lc_name = lc $alias;
    my $loose = &utf8::_loose_name($lc_name);
    next if exists $props{$loose};  # Skip if already tested
    $props{$loose} = 1;
    my $mod_name = "$extra_chars$alias";    # Tests loose matching
    my @aliases = prop_aliases($mod_name);
    my $found_it = grep { &utf8::_loose_name(lc $_) eq $lc_name } @aliases;
    if ($found_it) {
        pass("prop_aliases: '$lc_name' is listed as an alias for '$mod_name'");
    }
    elsif ($lc_name =~ /l[_&]$/) {

        # These two names are special in that they don't appear in the
        # returned list because they are discouraged from use.  Verify
        # that they return the same list as a non-discouraged version.
        my @LC = prop_aliases('Is_LC');
        is_deeply(\@aliases, \@LC, "prop_aliases: '$lc_name' returns the same list as 'Is_LC'");
    }
    else {
        my $stripped = $lc_name =~ s/^is//;

        # Could be that the input includes a prefix 'is', which is rarely
        # returned as an alias, so having successfully stripped it off above,
        # try again.
        if ($stripped) {
            $found_it = grep { &utf8::_loose_name(lc $_) eq $lc_name } @aliases;
        }

        # If that didn't work, it could be that it's a block, which is always
        # returned with a leading 'In_' to avoid ambiguity.  Try comparing
        # with that stripped off.
        if (! $found_it) {
            $found_it = grep { &utf8::_loose_name(s/^In_(.*)/\L$1/r) eq $lc_name }
                              @aliases;
            # Could check that is a real block, but tests for invmap will
            # likely pickup any errors, since this will be tested there.
            $lc_name = "in$lc_name" if $found_it;   # Change for message below
        }
        my $message = "prop_aliases: '$lc_name' is listed as an alias for '$mod_name'";
        ($found_it) ? pass($message) : fail($message);
    }
}

my $done_equals = 0;
foreach my $alias (keys %utf8::stricter_to_file_of) {
    if ($alias =~ /=/) {    # Only test one case where there is an equals
        next if $done_equals;
        $done_equals = 1;
    }
    my $lc_name = lc $alias;
    my @list = prop_aliases($alias);
    if ($alias =~ /^_/) {
        is(@list, 0, "prop_aliases: '$lc_name' returns an empty list since it is internal_only");
    }
    elsif ($alias =~ /=/) {
        is(@list, 0, "prop_aliases: '$lc_name' returns an empty list since is illegal property name");
    }
    else {
        ok((grep { lc $_ eq $lc_name } @list),
                "prop_aliases: '$lc_name' is listed as an alias for '$alias'");
    }
}

use Unicode::UCD qw(prop_value_aliases);

is(prop_value_aliases("unknown property", "unknown value"), undef,
    "prop_value_aliases(<unknown property>, <unknown value>) returns <undef>");
is(prop_value_aliases(undef, undef), undef,
                           "prop_value_aliases(undef, undef) returns <undef>");
is((prop_value_aliases("na", "A")), "A", "test that prop_value_aliases returns its input for properties that don't have synonyms");
is(prop_value_aliases("isgc", "C"), undef, "prop_value_aliases('isgc', 'C') returns <undef> since is not covered Perl extension");
is(prop_value_aliases("gc", "isC"), undef, "prop_value_aliases('gc', 'isC') returns <undef> since is not covered Perl extension");

# We have no way of knowing if mktables omitted a Perl extension that it
# shouldn't have, but we can check if it omitted an official Unicode property
# name synonym.  And for those, we can check if the short and full names are
# correct.

my %pva_tested;   # List of things already tested.
open my $propvalues, "<", "../lib/unicore/PropValueAliases.txt"
     or die "Can't open Unicode PropValueAliases.txt";
while (<$propvalues>) {
    s/\s*#.*//;           # Remove comments
    next if /^\s* $/x;    # Ignore empty and comment lines
    chomp;

    my @fields = split /\s*;\s*/; # Fields are separated by semi-colons
    my $prop = shift @fields;   # 0th field is the property,
    my $count = 0;  # 0th field in line (after shifting off the property) is
                    # short name; 1th is long name
    my $short_name;
    my @names_via_short;    # Saves the values between iterations

    # The property on the lhs of the = is always loosely matched.  Add in
    # characters that are ignored under loose matching to test that
    my $mod_prop = "$extra_chars$prop";

    if ($fields[0] eq 'n/a') {  # See comments in input file, essentially
                                # means full name and short name are identical
        $fields[0] = $fields[1];
    }
    elsif ($fields[0] ne $fields[1]
           && &utf8::_loose_name(lc $fields[0])
               eq &utf8::_loose_name(lc $fields[1])
           && $fields[1] !~ /[[:upper:]]/)
    {
        # Also, there is a bug in the file in which "n/a" is omitted, and
        # the two fields are identical except for case, and the full name
        # is all lower case.  Copy the "short" name unto the full one to
        # give it some upper case.

        $fields[1] = $fields[0];
    }

    # The ccc property in the file is special; has an extra numeric field
    # (0th), which should go at the end, since we use the next two fields as
    # the short and full names, respectively.  See comments in input file.
    splice (@fields, 0, 0, splice(@fields, 1, 2)) if $prop eq 'ccc';

    my $loose_prop = &utf8::_loose_name(lc $prop);
    my $suppressed = grep { $_ eq $loose_prop }
                          @Unicode::UCD::suppressed_properties;
    foreach my $value (@fields) {
        if ($suppressed) {
            is(prop_value_aliases($prop, $value), undef, "prop_value_aliases('$prop', '$value') returns undef for suppressed property $prop");
            next;
        }
        elsif (grep { $_ eq ("$loose_prop=" . &utf8::_loose_name(lc $value)) } @Unicode::UCD::suppressed_properties) {
            is(prop_value_aliases($prop, $value), undef, "prop_value_aliases('$prop', '$value') returns undef for suppressed property $prop=$value");
            next;
        }

        # Add in test for loose matching.
        my $mod_value = "$extra_chars$value";

        # If the value is a number, optionally negative, including a floating
        # point or rational numer, it should be only strictly matched, so the
        # loose matching should fail.
        if ($value =~ / ^ -? \d+ (?: [\/.] \d+ )? $ /x) {
            is(prop_value_aliases($mod_prop, $mod_value), undef, "prop_value_aliases('$mod_prop', '$mod_value') returns undef because '$mod_value' should be strictly matched");

            # And reset so below tests just the strict matching.
            $mod_value = $value;
        }

        if ($count == 0) {

            @names_via_short = prop_value_aliases($mod_prop, $mod_value);

            # If the 0th test fails, no sense in continuing with the others
            last unless is($names_via_short[0], $value, "prop_value_aliases: In '$prop', '$value' is the short name for '$mod_value'");
            $short_name = $value;
        }
        elsif ($count == 1) {

            # Some properties have the same short and full name; no sense
            # repeating the test if the same.
            if ($value ne $short_name) {
                my @names_via_full =
                            prop_value_aliases($mod_prop, $mod_value);
                is_deeply(\@names_via_full, \@names_via_short, "In '$prop', prop_value_aliases() returns the same list for both '$short_name' and '$mod_value'");
            }

            # Tests scalar context
            is(prop_value_aliases($prop, $short_name), $value, "'$value' is the long name for prop_value_aliases('$prop', '$short_name')");
        }
        else {
            my @all_names = prop_value_aliases($mod_prop, $mod_value);
            is_deeply(\@all_names, \@names_via_short, "In '$prop', prop_value_aliases() returns the same list for both '$short_name' and '$mod_value'");
            ok((grep { &utf8::_loose_name(lc $_) eq &utf8::_loose_name(lc $value) } prop_value_aliases($prop, $short_name)), "'$value' is listed as an alias for prop_value_aliases('$prop', '$short_name')");
        }

        $pva_tested{&utf8::_loose_name(lc $prop) . "=" . &utf8::_loose_name(lc $value)} = 1;
        $count++;
    }
}

# And test as best we can, the non-official pva's that mktables generates.
foreach my $hash (\%utf8::loose_to_file_of, \%utf8::stricter_to_file_of) {
    foreach my $test (keys %$hash) {
        next if exists $pva_tested{$test};  # Skip if already tested

        my ($prop, $value) = split "=", $test;
        next unless defined $value; # prop_value_aliases() requires an input
                                    # 'value'
        my $mod_value;
        if ($hash == \%utf8::loose_to_file_of) {

            # Add extra characters to test loose-match rhs value
            $mod_value = "$extra_chars$value";
        }
        else { # Here value is strictly matched.

            # Extra elements are added by mktables to this hash so that
            # something like "age=6.0" has a synonym of "age=6".  It's not
            # clear to me (khw) if we should be encouraging those synonyms, so
            # don't test for them.
            next if $value !~ /\D/ && exists $hash->{"$prop=$value.0"};

            # Verify that loose matching fails when only strict is called for.
            next unless is(prop_value_aliases($prop, "$extra_chars$value"), undef,
                        "prop_value_aliases('$prop', '$extra_chars$value') returns undef since '$value' should be strictly matched"),

            # Strict matching does allow for underscores between digits.  Test
            # for that.
            $mod_value = $value;
            while ($mod_value =~ s/(\d)(\d)/$1_$2/g) {}
        }

        # The lhs property is always loosely matched, so add in extra
        # characters to test that.
        my $mod_prop = "$extra_chars$prop";

        if ($prop eq 'gc' && $value =~ /l[_&]$/) {
            # These two names are special in that they don't appear in the
            # returned list because they are discouraged from use.  Verify
            # that they return the same list as a non-discouraged version.
            my @LC = prop_value_aliases('gc', 'lc');
            my @l_ = prop_value_aliases($mod_prop, $mod_value);
            is_deeply(\@l_, \@LC, "prop_value_aliases('$mod_prop', '$mod_value) returns the same list as prop_value_aliases('gc', 'lc')");
        }
        else {
            ok((grep { &utf8::_loose_name(lc $_) eq &utf8::_loose_name(lc $value) }
                prop_value_aliases($mod_prop, $mod_value)),
                "'$value' is listed as an alias for prop_value_aliases('$mod_prop', '$mod_value')");
        }
    }
}

undef %pva_tested;

no warnings 'once'; # We use some values once from 'required' modules.

use Unicode::UCD qw(prop_invlist prop_invmap MAX_CP);

# There were some problems with caching interfering with prop_invlist() vs
# prop_invmap() on binary properties, and also between the 3 properties where
# Perl used the same 'To' name as another property (see utf8_heavy.pl).
# So, before testing all of prop_invlist(),
#   1)  call prop_invmap() to try both orders of these name issues.  This uses
#       up two of the 3 properties;  the third will be left so that invlist()
#       on it gets called before invmap()
#   2)  call prop_invmap() on a generic binary property, ahead of invlist().
# This should test that the caching works in both directions.

# These properties are not stable between Unicode versions, but the first few
# elements are; just look at the first element to see if are getting the
# distinction right.  The general inversion map testing below will test the
# whole thing.
my $prop = "uc";
my ($invlist_ref, $invmap_ref, $format, $missing) = prop_invmap($prop);
is($format, 'cl', "prop_invmap() format of '$prop' is 'cl'");
is($missing, '<code point>', "prop_invmap() missing of '$prop' is '<code point>'");
is($invlist_ref->[1], 0x61, "prop_invmap('$prop') list[1] is 0x61");
is($invmap_ref->[1], 0x41, "prop_invmap('$prop') map[1] is 0x41");

$prop = "upper";
($invlist_ref, $invmap_ref, $format, $missing) = prop_invmap($prop);
is($format, 's', "prop_invmap() format of '$prop' is 'cl'");
is($missing, 'N', "prop_invmap() missing of '$prop' is '<code point>'");
is($invlist_ref->[1], 0x41, "prop_invmap('$prop') list[1] is 0x41");
is($invmap_ref->[1], 'Y', "prop_invmap('$prop') map[1] is 'Y'");

$prop = "lower";
($invlist_ref, $invmap_ref, $format, $missing) = prop_invmap($prop);
is($format, 's', "prop_invmap() format of '$prop' is 'cl'");
is($missing, 'N', "prop_invmap() missing of '$prop' is '<code point>'");
is($invlist_ref->[1], 0x61, "prop_invmap('$prop') list[1] is 0x61");
is($invmap_ref->[1], 'Y', "prop_invmap('$prop') map[1] is 'Y'");

$prop = "lc";
($invlist_ref, $invmap_ref, $format, $missing) = prop_invmap($prop);
is($format, 'cl', "prop_invmap() format of '$prop' is 'cl'");
is($missing, '<code point>', "prop_invmap() missing of '$prop' is '<code point>'");
is($invlist_ref->[1], 0x41, "prop_invmap('$prop') list[1] is 0x41");
is($invmap_ref->[1], 0x61, "prop_invmap('$prop') map[1] is 0x61");

# This property is stable and small, so can test all of it
$prop = "ASCII_Hex_Digit";
($invlist_ref, $invmap_ref, $format, $missing) = prop_invmap($prop);
is($format, 's', "prop_invmap() format of '$prop' is 's'");
is($missing, 'N', "prop_invmap() missing of '$prop' is 'N'");
is_deeply($invlist_ref, [ 0x0000, 0x0030, 0x003A, 0x0041,
                          0x0047, 0x0061, 0x0067, 0x110000 ],
          "prop_invmap('$prop') code point list is correct");
is_deeply($invmap_ref, [ 'N', 'Y', 'N', 'Y', 'N', 'Y', 'N', 'N' ] ,
          "prop_invmap('$prop') map list is correct");

is(prop_invlist("Unknown property"), undef, "prop_invlist(<Unknown property>) returns undef");
is(prop_invlist(undef), undef, "prop_invlist(undef) returns undef");
is(prop_invlist("Any"), 2, "prop_invlist('Any') returns the number of elements in scalar context");
my @invlist = prop_invlist("Is_Any");
is_deeply(\@invlist, [ 0, 0x110000 ], "prop_invlist works on 'Is_' prefixes");
is(prop_invlist("Is_Is_Any"), undef, "prop_invlist('Is_Is_Any') returns <undef> since two is's");

use Storable qw(dclone);

is(prop_invlist("InKana"), undef, "prop_invlist(<user-defined property returns undef>)");

# The way both the tests for invlist and invmap work is that they take the
# lists returned by the functions and construct from them what the original
# file should look like, which are then compared with the file.  If they are
# identical, the test passes.  What this tests isn't that the results are
# correct, but that invlist and invmap haven't introduced errors beyond what
# are there in the files.  As a small hedge against that, test some
# prop_invlist() tables fully with the known correct result.  We choose
# ASCII_Hex_Digit again, as it is stable.
@invlist = prop_invlist("AHex");
is_deeply(\@invlist, [ 0x0030, 0x003A, 0x0041,
                                 0x0047, 0x0061, 0x0067 ],
          "prop_invlist('AHex') is exactly the expected set of points");
@invlist = prop_invlist("AHex=f");
is_deeply(\@invlist, [ 0x0000, 0x0030, 0x003A, 0x0041,
                                 0x0047, 0x0061, 0x0067 ],
          "prop_invlist('AHex=f') is exactly the expected set of points");

sub fail_with_diff ($$$$) {
    # For use below to output better messages
    my ($prop, $official, $constructed, $tested_function_name) = @_;

    is($constructed, $official, "$tested_function_name('$prop')");
    diag("Comment out lines " . (__LINE__ - 1) . " through " . (__LINE__ + 1) . " in '$0' on Un*x-like systems to see just the differences.  Uses the 'diff' first in your \$PATH");
    return;

    fail("$tested_function_name('$prop')");

    require File::Temp;
    my $off = File::Temp->new();
    chomp $official;
    print $off $official, "\n";
    close $off || die "Can't close official";

    chomp $constructed;
    my $gend = File::Temp->new();
    print $gend $constructed, "\n";
    close $gend || die "Can't close gend";

    my $diff = File::Temp->new();
    system("diff $off $gend > $diff");

    open my $fh, "<", $diff || die "Can't open $diff";
    my @diffs = <$fh>;
    diag("In the diff output below '<' marks lines from the filesystem tables;\n'>' are from $tested_function_name()");
    diag(@diffs);
}

my %tested_invlist;

# Look at everything we think that mktables tells us exists, both loose and
# strict
foreach my $set_of_tables (\%utf8::stricter_to_file_of, \%utf8::loose_to_file_of)
{
    foreach my $table (keys %$set_of_tables) {

        my $mod_table;
        my ($prop_only, $value) = split "=", $table;
        if (defined $value) {

            # If this is to be loose matched, add in characters to test that.
            if ($set_of_tables == \%utf8::loose_to_file_of) {
                $value = "$extra_chars$value";
            }
            else {  # Strict match

                # Verify that loose matching fails when only strict is called
                # for.
                next unless is(prop_invlist("$prop_only=$extra_chars$value"), undef, "prop_invlist('$prop_only=$extra_chars$value') returns undef since should be strictly matched");

                # Strict matching does allow for underscores between digits.
                # Test for that.
                while ($value =~ s/(\d)(\d)/$1_$2/g) {}
            }

            # The property portion in compound form specifications always
            # matches loosely
            $mod_table = "$extra_chars$prop_only = $value";
        }
        else {  # Single-form.

            # Like above, use looose if required, and insert underscores
            # between digits if strict.
            if ($set_of_tables == \%utf8::loose_to_file_of) {
                $mod_table = "$extra_chars$table";
            }
            else {
                $mod_table = $table;
                while ($mod_table =~ s/(\d)(\d)/$1_$2/g) {}
            }
        }

        my @tested = prop_invlist($mod_table);
        if ($table =~ /^_/) {
            is(@tested, 0, "prop_invlist('$mod_table') returns an empty list since is internal-only");
            next;
        }

        # If we have already tested a property that uses the same file, this
        # list should be identical to the one that was tested, and can bypass
        # everything else.
        my $file = $set_of_tables->{$table};
        if (exists $tested_invlist{$file}) {
            is_deeply(\@tested, $tested_invlist{$file}, "prop_invlist('$mod_table') gave same results as its name synonym");
            next;
        }
        $tested_invlist{$file} = dclone \@tested;

        # A leading '!' in the file name means that it is to be inverted.
        my $invert = $file =~ s/^!//;
        my $official = do "unicore/lib/$file.pl";

        # Get rid of any trailing space and comments in the file.
        $official =~ s/\s*(#.*)?$//mg;
        chomp $official;

        # If we are to test against an inverted file, it is easier to invert
        # our array than the file.
        # The file only is valid for Unicode code points, while the inversion
        # list is valid for all possible code points.  Therefore, we must test
        # just the Unicode part against the file.  Later we will test for
        # the non-Unicode part.

        my $before_invert;  # Saves the pre-inverted table.
        if ($invert) {
            $before_invert = dclone \@tested;
            if (@tested && $tested[0] == 0) {
                shift @tested;
            } else {
                unshift @tested, 0;
            }
            if (@tested && $tested[-1] == 0x110000) {
                pop @tested;
            }
            else {
                push @tested, 0x110000;
            }
        }

        # Now construct a string from the list that should match the file.
        # The file gives ranges of code points with starting and ending values
        # in hex, like this:
        # 0041\t005A
        # 0061\t007A
        # 00AA
        # Our list has even numbered elements start ranges that are in the
        # list, and odd ones that aren't in the list.  Therefore the odd
        # numbered ones are one beyond the end of the previous range, but
        # otherwise don't get reflected in the file.
        my $tested = "";
        my $i = 0;
        for (; $i < @tested - 1; $i += 2) {
            my $start = $tested[$i];
            my $end = $tested[$i+1] - 1;
            if ($start == $end) {
                $tested .= sprintf("%04X\n", $start);
            }
            else {
                $tested .= sprintf "%04X\t%04X\n", $start, $end;
            }
        }

        # As mentioned earlier, the disk files only go up through Unicode,
        # whereas the prop_invlist() ones go as high as necessary.  The
        # comparison is only valid through max Unicode.
        if ($i == @tested - 1 && $tested[$i] <= 0x10FFFF) {
            $tested .= sprintf("%04X\t10FFFF\n", $tested[$i]);
        }
        chomp $tested;
        if ($tested ne $official) {
            fail_with_diff($mod_table, $official, $tested, "prop_invlist");
            next;
        }

        # Here, it matched the table.  Now need to check for if it is correct
        # for beyond Unicode.  First, calculate if is the default table or
        # not.  This is the same algorithm as used internally in
        # prop_invlist(), so if it is wrong there, this test won't catch it.
        my $prop = lc $table;
        ($prop_only, $table) = split /\s*[:=]\s*/, $prop;
        if (defined $table) {

            # May have optional prefixed 'is'
            $prop = &utf8::_loose_name($prop_only) =~ s/^is//r;
            $prop = $utf8::loose_property_name_of{$prop};
            $prop .= "=" . &utf8::_loose_name($table);
        }
        else {
            $prop = &utf8::_loose_name($prop);
        }
        my $is_default = exists $Unicode::UCD::loose_defaults{$prop};

        @tested = @$before_invert if $invert;    # Use the original
        if (@tested % 2 == 0) {

            # If there are an even number of elements, the final one starts a
            # range (going to infinity) of code points that are not in the
            # list.
            if ($is_default) {
                fail("prop_invlist('$mod_table')");
                diag("default table doesn't goto infinity");
                use Data::Dumper;
                diag Dumper \@tested;
                next;
            }
        }
        else {
            # An odd number of elements means the final one starts a range
            # (going to infinity of code points that are in the list.
            if (! $is_default) {
                fail("prop_invlist('$mod_table')");
                diag("non-default table needs to stop in the Unicode range");
                use Data::Dumper;
                diag Dumper \@tested;
                next;
            }
        }

        pass("prop_invlist('$mod_table')");
    }
}

# Now test prop_invmap().

@list = prop_invmap("Unknown property");
is (@list, 0, "prop_invmap(<Unknown property>) returns an empty list");
@list = prop_invmap(undef);
is (@list, 0, "prop_invmap(undef) returns an empty list");
ok (! eval "prop_invmap('gc')" && $@ ne "",
                                "prop_invmap('gc') dies in scalar context");
@list = prop_invmap("_X_Begin");
is (@list, 0, "prop_invmap(<internal property>) returns an empty list");
@list = prop_invmap("InKana");
is(@list, 0, "prop_invmap(<user-defined property returns undef>)");
@list = prop_invmap("Perl_Decomposition_Mapping"), undef,
is(@list, 0, "prop_invmap('Perl_Decomposition_Mapping') returns <undef> since internal-Perl-only");
@list = prop_invmap("Perl_Charnames"), undef,
is(@list, 0, "prop_invmap('Perl_Charnames') returns <undef> since internal-Perl-only");
@list = prop_invmap("Is_Is_Any");
is(@list, 0, "prop_invmap('Is_Is_Any') returns <undef> since two is's");

# The set of properties to test on has already been compiled into %props by
# the prop_aliases() tests.

my %tested_invmaps;

# Like prop_invlist(), prop_invmap() is tested by comparing the results
# returned by the function with the tables that mktables generates.  Some of
# these tables are directly stored as files on disk, in either the unicore or
# unicore/To directories, and most should be listed in the mktables generated
# hash %utf8::loose_property_to_file_of, with a few additional ones that this
# handles specially.  For these, the files are read in directly, massaged, and
# compared with what invmap() returns.  The SPECIALS hash in some of these
# files overrides values in the main part of the file.
#
# The other properties are tested indirectly by generating all the possible
# inversion lists for the property, and seeing if those match the inversion
# lists returned by prop_invlist(), which has already been tested.

PROPERTY:
foreach my $prop (keys %props) {
    my $loose_prop = &utf8::_loose_name(lc $prop);
    my $suppressed = grep { $_ eq $loose_prop }
                          @Unicode::UCD::suppressed_properties;

    # Find the short and full names that this property goes by
    my ($name, $full_name) = prop_aliases($prop);
    if (! $name) {
        if (! $suppressed) {
            fail("prop_invmap('$prop')");
            diag("is unknown to prop_aliases(), and we need it in order to test prop_invmap");
        }
        next PROPERTY;
    }

    # Normalize the short name, as it is stored in the hashes under the
    # normalized version.
    $name = &utf8::_loose_name(lc $name);

    # Add in the characters that are supposed to be ignored to test loose
    # matching, which the tested function applies to all properties
    my $mod_prop = "$extra_chars$prop";

    my ($invlist_ref, $invmap_ref, $format, $missing) = prop_invmap($mod_prop);
    my $return_ref = [ $invlist_ref, $invmap_ref, $format, $missing ];

    # If have already tested this property under a different name, merely
    # compare the return from now with the saved one from before.
    if (exists $tested_invmaps{$name}) {
        is_deeply($return_ref, $tested_invmaps{$name}, "prop_invmap('$mod_prop') gave same results as its synonym, '$name'");
        next PROPERTY;
    }
    $tested_invmaps{$name} = dclone $return_ref;

    # If prop_invmap() returned nothing, is ok iff is a property whose file is
    # not generated.
    if ($suppressed) {
        if (defined $format) {
            fail("prop_invmap('$mod_prop')");
            diag("did not return undef for suppressed property $prop");
        }
        next PROPERTY;
    }
    elsif (!defined $format) {
        fail("prop_invmap('$mod_prop')");
        diag("'$prop' is unknown to prop_invmap()");
        next PROPERTY;
    }

    # The two parallel arrays must have the same number of elements.
    if (@$invlist_ref != @$invmap_ref) {
        fail("prop_invmap('$mod_prop')");
        diag("invlist has "
             . scalar @$invlist_ref
             . " while invmap has "
             . scalar @$invmap_ref
             . " elements");
        next PROPERTY;
    }

    # The last element must be for the above-Unicode code points, and must be
    # for the default value.
    if ($invlist_ref->[-1] != 0x110000) {
        fail("prop_invmap('$mod_prop')");
        diag("The last inversion list element is not 0x110000");
        next PROPERTY;
    }
    if ($invmap_ref->[-1] ne $missing) {
        fail("prop_invmap('$mod_prop')");
        diag("The last inversion list element is '$invmap_ref->[-1]', and should be '$missing'");
        next PROPERTY;
    }

    if ($name eq 'bmg') {   # This one has an atypical $missing
        if ($missing ne "") {
            fail("prop_invmap('$mod_prop')");
            diag("The missings should be \"\"; got '$missing'");
            next PROPERTY;
        }
    }
    elsif ($format =~ /^ [cd] /x) {
        if ($missing ne "<code point>") {
            fail("prop_invmap('$mod_prop')");
            diag("The missings should be '<code point>'; got '$missing'");
            next PROPERTY;
        }
    }
    elsif ($missing =~ /[<>]/) {
        fail("prop_invmap('$mod_prop')");
        diag("The missings should NOT be something with <...>'");
        next PROPERTY;

        # I don't want to hard code in what all the missings should be, so
        # those don't get fully tested.
    }

    # Certain properties don't have their own files, but must be constructed
    # using proxies.
    my $proxy_prop = $name;
    if ($full_name eq 'Present_In') {
        $proxy_prop = "age";    # The maps for these two props are identical
    }
    elsif ($full_name eq 'Simple_Case_Folding'
           || $full_name =~ /Simple_ (.) .*? case_Mapping  /x)
    {
        if ($full_name eq 'Simple_Case_Folding') {
            $proxy_prop = 'cf';
        }
        else {
            # We captured the U, L, or T, leading to uc, lc, or tc.
            $proxy_prop = lc $1 . "c";
        }
        if ($format ne "c") {
            fail("prop_invmap('$mod_prop')");
            diag("The format should be 'c'; got '$format'");
            next PROPERTY;
        }
    }

    my $base_file;
    my $official;

    # Handle the properties that have full disk files for them (except the
    # Name property which is structurally enough different that it is handled
    # separately below.)
    if ($name ne 'na'
        && ($name eq 'blk'
            || defined
                    ($base_file = $utf8::loose_property_to_file_of{$proxy_prop})
            || exists $utf8::loose_to_file_of{$proxy_prop}
            || $name eq "dm"))
    {
        # In the above, blk is done unconditionally, as we need to test that
        # the old-style block names are returned, even if mktables has
        # generated a file for the new-style; the test for dm comes afterward,
        # so that if a file has been generated for it explicitly, we use that
        # file (which is valid, unlike blk) instead of the combo
        # Decomposition.pl files.
        my $file;
        my $is_binary = 0;
        if ($name eq 'blk') {

            # The blk property is special.  The original file with old block
            # names is retained, and the default is to not write out a
            # new-name file.  What we do is get the old names into a data
            # structure, and from that create what the new file would look
            # like.  $base_file is needed to be defined, just to avoid a
            # message below.
            $base_file = "This is a dummy name";
            my $blocks_ref = charblocks();
            $official = "";
            for my $range (sort { $a->[0][0] <=> $b->[0][0] }
                           values %$blocks_ref)
            {
                # Translate the charblocks() data structure to what the file
                # would like.
                $official .= sprintf"%04X\t%04X\t%s\n",
                             $range->[0][0],
                             $range->[0][1],
                             $range->[0][2];
            }
        }
        else {
            $base_file = "Decomposition" if $format eq 'd';

            # Above leaves $base_file undefined only if it came from the hash
            # below.  This should happen only when it is a binary property
            # (and are accessing via a single-form name, like 'In_Latin1'),
            # and so it is stored in a different directory than the To ones.
            # XXX Currently, the only cases where it is complemented are the
            # ones that have no code points.  And it works out for these that
            # 1) complementing them, and then 2) adding or subtracting the
            # initial 0 and final 110000 cancel each other out.  But further
            # work would be needed in the unlikely event that an inverted
            # property comes along without these characteristics
            if (!defined $base_file) {
                $base_file = $utf8::loose_to_file_of{$proxy_prop};
                $is_binary = ($base_file =~ s/^!//) ? -1 : 1;
                $base_file = "lib/$base_file";
            }

            # Read in the file
            $file = "unicore/$base_file.pl";
            $official = do $file;

            # Get rid of any trailing space and comments in the file.
            $official =~ s/\s*(#.*)?$//mg;

            # Decomposition.pl also has the <compatible> types in it, which
            # should be removed.
            $official =~ s/<.*?> //mg if $format eq 'd';
        }
        chomp $official;

        # If there are any special elements, get a reference to them.
        my $specials_ref = $utf8::file_to_swash_name{$base_file};
        if ($specials_ref) {
            $specials_ref = $utf8::SwashInfo{$specials_ref}{'specials_name'};
            if ($specials_ref) {

                # Convert from the name to the actual reference.
                no strict 'refs';
                $specials_ref = \%{$specials_ref};
            }
        }

        # Certain of the proxy properties have to be adjusted to match the
        # real ones.
        if (($proxy_prop ne $name && $full_name =~ 'Mapping')
            || $full_name eq 'Case_Folding')
        {

            # Here we have either
            #   1) Case_Folding; or
            #   2) a proxy that is a full mapping, which means that what the
            #      real property is is the equivalent simple mapping.
            # In both cases, the file will have a standard list containing
            # simple mappings (to a single code point), and a specials hash
            # which contains all the mappings that are to multiple code
            # points.  First, extract a list containing all the file's simple
            # mappings.
            my @list;
            for (split "\n", $official) {
                my ($start, $end, $value) = / ^ (.+?) \t (.*?) \t (.+?)
                                                \s* ( \# .* )?
                                                $ /x;
                $end = $start if $end eq "";
                if ($end ne $start) {
                    fail("prop_invmap('$mod_prop')");
                    diag("This test is expecting only single code point ranges in $file.pl");
                    next PROPERTY;
                }
                push @list, [ hex $start, $value ];
            }

            # For Case_Folding, the file contains all the simple mappings,
            # including the ones that are overridden by the specials.  These
            # need to be removed as the list is for just the full ones.  For
            # the other files, the proxy is missing the simple mappings that
            # are overridden by the specials, so we need to add them.

            # For the missing simples, we get the correct values by calling
            # charinfo().  Set up which element of the hash returned by
            # charinfo to look at
            my $charinfo_element;
            if ($full_name =~ / ^ Simple_ (Lower | Upper | Title) case_Mapping/x)
            {
                $charinfo_element = lc $1;  # e.g. Upper is referred to by the
                                            # key 'upper' in the charinfo()
                                            # returned hash
            }

            # Go through any special mappings one by one.  They are packed.
            my $i = 0;
            foreach my $utf8_cp (sort keys %$specials_ref) {
                my $cp = unpack("C0U", $utf8_cp);

                # Get what the simple value for this should be; either nothing
                # for Case_Folding, or what charinfo returns for the others.
                my $simple = ($full_name eq "Case_Folding")
                             ? ""
                             : charinfo($cp)->{$charinfo_element};

                # And create an entry to add to the list, if appropriate
                my $replacement;
                $replacement = [ $cp,  $simple ] if $simple ne "";

                # Find the spot in the @list of simple mappings that this
                # special applies to; uses a linear search.
                while ($i < @list -1 ) {
                    last if  $cp <= $list[$i][0];
                    $i++;
                }

                #note  $i-1 . ": " . join " => ", @{$list[$i-1]};
                #note  $i-0 . ": " . join " => ", @{$list[$i-0]};
                #note  $i+1 . ": " . join " => ", @{$list[$i+1]};

                if (! defined $replacement) {

                    # Here, are to remove any existing entry for this code
                    # point.
                    next if $cp != $list[$i][0];
                    splice @list, $i, 1;
                }
                elsif ($cp == $list[$i][0]) {

                    # Here, are to add something, but there is an existing
                    # entry, so this just replaces it.
                    $list[$i] = $replacement;
                }
                else {

                    # Here, are to add something, and there isn't an existing
                    # entry.
                    splice @list, $i, 0, $replacement;
                }

                #note __LINE__ . ": $cp";
                #note  $i-1 . ": " . join " => ", @{$list[$i-1]};
                #note  $i-0 . ": " . join " => ", @{$list[$i-0]};
                #note  $i+1 . ": " . join " => ", @{$list[$i+1]};
            }

            # Here, have gone through all the specials, modifying @list as
            # needed.  Turn it back into what the file should look like.
            $official = join "\n", map { sprintf "%04X\t\t%s", @$_ } @list;

            # And, no longer need the specials for the simple mappings, as are
            # all incorporated into $official
            undef $specials_ref if $full_name ne 'Case_Folding';
        }
        elsif ($full_name eq 'Simple_Case_Folding') {

            # This property has everything in the regular array, and the
            # specials are superfluous.
            undef $specials_ref if $full_name ne 'Case_Folding';
        }

        # Here, in $official, we have what the file looks like, or should like
        # if we've had to fix it up.  Now take the invmap() output and reverse
        # engineer from that what the file should look like.  Each iteration
        # appends the next line to the running string.
        my $tested_map = "";

        # Create a copy of the file's specials hash.  (It has been undef'd if
        # we know it isn't relevant to this property, so if it exists, it's an
        # error or is relevant).  As we go along, we delete from that copy.
        # If a delete fails, or something is left over after we are done,
        # it's an error
        my %specials = %$specials_ref if $specials_ref;

        # The extra -1 is because the final element has been tested above to
        # be for anything above Unicode.  The file doesn't go that high.
        for my $i (0 .. @$invlist_ref - 1 - 1) {

            # If the map element is a reference, have to stringify it (but
            # don't do so if the format doesn't allow references, so that an
            # improper format will generate an error.
            if (ref $invmap_ref->[$i]
                && ($format eq 'd' || $format =~ /^ . l /x))
            {
                # The stringification depends on the format.  At the time of
                # this writing, all 'sl' formats are space separated.
                if ($format eq 'sl') {
                    $invmap_ref->[$i] = join " ", @{$invmap_ref->[$i]};
                }
                elsif ($format =~ / ^ cl e? $/x) {

                    # For a cl property, the stringified result should be in
                    # the specials hash.  The key is the packed code point,
                    # and the value is the packed map.
                    my $value;
                    if (! defined ($value = delete $specials{pack("C0U", $invlist_ref->[$i]) })) {
                        fail("prop_invmap('$mod_prop')");
                        diag(sprintf "There was no specials element for %04X", $invlist_ref->[$i]);
                        next PROPERTY;
                    }
                    my $packed = pack "U*", @{$invmap_ref->[$i]};
                    if ($value ne $packed) {
                        fail("prop_invmap('$mod_prop')");
                        diag(sprintf "For %04X, expected the mapping to be '$packed', but got '$value'");
                        next PROPERTY;
                    }

                    # As this doesn't get tested when we later compare with
                    # the actual file, it could be out of order and we
                    # wouldn't know it.
                    if (($i > 0 && $invlist_ref->[$i] <= $invlist_ref->[$i-1])
                        || $invlist_ref->[$i] >= $invlist_ref->[$i+1])
                    {
                        fail("prop_invmap('$mod_prop')");
                        diag(sprintf "Range beginning at %04X is out-of-order.", $invlist_ref->[$i]);
                        next PROPERTY;
                    }
                    next;
                }
                elsif ($format eq 'd') {

                    # The decomposition mapping file has the code points as
                    # a string of space-separated hex constants.
                    $invmap_ref->[$i] = join " ", map { sprintf "%04X", $_ } @{$invmap_ref->[$i]};
                }
                else {
                    fail("prop_invmap('$mod_prop')");
                    diag("Can't handle format '$format'");
                    next PROPERTY;
                }
            }
            elsif ($format eq 'cle' && $invmap_ref->[$i] eq "") {

                # cle properties have maps to the empty string that also
                # should be in the specials hash, with the key the packed code
                # point, and the map just empty.
                my $value;
                if (! defined ($value = delete $specials{pack("C0U", $invlist_ref->[$i]) })) {
                    fail("prop_invmap('$mod_prop')");
                    diag(sprintf "There was no specials element for %04X", $invlist_ref->[$i]);
                    next PROPERTY;
                }
                if ($value ne "") {
                    fail("prop_invmap('$mod_prop')");
                    diag(sprintf "For %04X, expected the mapping to be \"\", but got '$value'", $invlist_ref->[$i]);
                    next PROPERTY;
                }

                # As this doesn't get tested when we later compare with
                # the actual file, it could be out of order and we
                # wouldn't know it.
                if (($i > 0 && $invlist_ref->[$i] <= $invlist_ref->[$i-1])
                    || $invlist_ref->[$i] >= $invlist_ref->[$i+1])
                {
                    fail("prop_invmap('$mod_prop')");
                    diag(sprintf "Range beginning at %04X is out-of-order.", $invlist_ref->[$i]);
                    next PROPERTY;
                }
                next;
            }
            elsif ($is_binary) { # These binary files don't have an explicit Y
                $invmap_ref->[$i] =~ s/Y//;
            }

            # The file doesn't include entries that map to $missing, so don't
            # include it in the built-up string.  But make sure that it is in
            # the correct order in the input.
            if ($invmap_ref->[$i] eq $missing) {
                if (($i > 0 && $invlist_ref->[$i] <= $invlist_ref->[$i-1])
                    || $invlist_ref->[$i] >= $invlist_ref->[$i+1])
                {
                    fail("prop_invmap('$mod_prop')");
                    diag(sprintf "Range beginning at %04X is out-of-order.", $invlist_ref->[$i]);
                    next PROPERTY;
                }
                next;
            }

            # 'c'-type and 'd' properties have the mapping expressed in hex in
            # the file
            if ($format =~ /^ [cd] /x) {

                # The d property has one entry which isn't in the file.
                # Ignore it, but make sure it is in order.
                if ($format eq 'd'
                    && $invmap_ref->[$i] eq '<hangul syllable>'
                    && $invlist_ref->[$i] == 0xAC00)
                {
                    if (($i > 0 && $invlist_ref->[$i] <= $invlist_ref->[$i-1])
                        || $invlist_ref->[$i] >= $invlist_ref->[$i+1])
                    {
                        fail("prop_invmap('$mod_prop')");
                        diag(sprintf "Range beginning at %04X is out-of-order.", $invlist_ref->[$i]);
                        next PROPERTY;
                    }
                    next;
                }
                $invmap_ref->[$i] = sprintf("%04X", $invmap_ref->[$i])
                                  if $invmap_ref->[$i] =~ / ^ [A-Fa-f0-9]+ $/x;
            }

            # Finally have figured out what the map column in the file should
            # be.  Append the line to the running string.
            my $start = $invlist_ref->[$i];
            my $end = $invlist_ref->[$i+1] - 1;
            $end = ($start == $end) ? "" : sprintf("%04X", $end);
            if ($invmap_ref->[$i] ne "") {
                $tested_map .= sprintf "%04X\t%s\t%s\n", $start, $end, $invmap_ref->[$i];
            }
            elsif ($end ne "") {
                $tested_map .= sprintf "%04X\t%s\n", $start, $end;
            }
            else {
                $tested_map .= sprintf "%04X\n", $start;
            }
        } # End of looping over all elements.

        # Here are done with generating what the file should look like

        chomp $tested_map;

        # And compare.
        if ($tested_map ne $official) {
            fail_with_diff($mod_prop, $official, $tested_map, "prop_invmap");
            next PROPERTY;
        }

        # There shouldn't be any specials unaccounted for.
        if (keys %specials) {
            fail("prop_invmap('$mod_prop')");
            diag("Unexpected specials: " . join ", ", keys %specials);
            next PROPERTY;
        }
    }
    elsif ($format eq 'n') {

        # Handle the Name property similar to the above.  But the file is
        # sufficiently different that it is more convenient to make a special
        # case for it.

        if ($missing ne "") {
            fail("prop_invmap('$mod_prop')");
            diag("The missings should be \"\"; got \"missing\"");
            next PROPERTY;
        }

        $official = do "unicore/Name.pl";

        # Get rid of the named sequences portion of the file.  These don't
        # have a tab before the first blank on a line.
        $official =~ s/ ^ [^\t]+ \  .*? \n //xmg;

        # And get rid of the controls.  These are named in the file, but
        # shouldn't be in the property.
        $official =~ s/ 00000 \t .* 0001F .*? \n//xs;
        $official =~ s/ 0007F \t .* 0009F .*? \n//xs;

        # This is slow; it gets rid of the aliases.  We look for lines that
        # are for the same code point as the previous line.  The previous line
        # will be a name_alias; and the current line will be the name.  Get
        # rid of the name_alias line.  This won't work if there are multiple
        # aliases for a given name.
        my @temp_names = split "\n", $official;
        my $previous_cp = "";
        for (my $i = 0; $i < @temp_names - 1; $i++) {
            $temp_names[$i] =~ /^ (.*)? \t /x;
            my $current_cp = $1;
            if ($current_cp eq $previous_cp) {
                splice @temp_names, $i - 1, 1;
                redo;
            }
            else {
                $previous_cp = $current_cp;
            }
        }
        $official = join "\n", @temp_names;
        undef @temp_names;
        chomp $official;

        # Here have adjusted the file.  We also have to adjust the returned
        # inversion map by checking and deleting all the lines in it that
        # won't be in the file.  These are the lines that have generated
        # things, like <hangul syllable>.
        my $tested_map = "";        # Current running string
        my @code_point_in_names =
                               @Unicode::UCD::code_points_ending_in_code_point;

        for my $i (0 .. @$invlist_ref - 1 - 1) {
            my $start = $invlist_ref->[$i];
            my $end = $invlist_ref->[$i+1] - 1;
            if ($invmap_ref->[$i] eq $missing) {
                if (($i > 0 && $invlist_ref->[$i] <= $invlist_ref->[$i-1])
                    || $invlist_ref->[$i] >= $invlist_ref->[$i+1])
                {
                    fail("prop_invmap('$mod_prop')");
                    diag(sprintf "Range beginning at %04X is out-of-order.", $invlist_ref->[$i]);
                    next PROPERTY;
                }
                next;
            }
            if ($invmap_ref->[$i] =~ / (.*) ( < .*? > )/x) {
                my $name = $1;
                my $type = $2;
                if (($i > 0 && $invlist_ref->[$i] <= $invlist_ref->[$i-1])
                    || $invlist_ref->[$i] >= $invlist_ref->[$i+1])
                {
                    fail("prop_invmap('$mod_prop')");
                    diag(sprintf "Range beginning at %04X is out-of-order.", $invlist_ref->[$i]);
                    next PROPERTY;
                }
                if ($type eq "<hangul syllable>") {
                    if ($name ne "") {
                        fail("prop_invmap('$mod_prop')");
                        diag("Unexpected text in $invmap_ref->[$i]");
                        next PROPERTY;
                    }
                    if ($start != 0xAC00) {
                        fail("prop_invmap('$mod_prop')");
                        diag(sprintf("<hangul syllables> should begin at 0xAC00, got %04X", $start));
                        next PROPERTY;
                    }
                    if ($end != $start + 11172 - 1) {
                        fail("prop_invmap('$mod_prop')");
                        diag(sprintf("<hangul syllables> should end at %04X, got %04X", $start + 11172 -1, $end));
                        next PROPERTY;
                    }
                }
                elsif ($type ne "<code point>") {
                    fail("prop_invmap('$mod_prop')");
                    diag("Unexpected text '$type' in $invmap_ref->[$i]");
                    next PROPERTY;
                }
                else {

                    # Look through the array of names that end in code points,
                    # and look for this start and end.  If not found is an
                    # error.  If found, delete it, and at the end, make sure
                    # have deleted everything.
                    for my $i (0 .. @code_point_in_names - 1) {
                        my $hash = $code_point_in_names[$i];
                        if ($hash->{'low'} == $start
                            && $hash->{'high'} == $end
                            && "$hash->{'name'}-" eq $name)
                        {
                            splice @code_point_in_names, $i, 1;
                            last;
                        }
                        else {
                            fail("prop_invmap('$mod_prop')");
                            diag("Unexpected code-point-in-name line '$invmap_ref->[$i]'");
                            next PROPERTY;
                        }
                    }
                }

                next;
            }

            # Have adjusted the map, as needed.  Append to running string.
            $end = ($start == $end) ? "" : sprintf("%05X", $end);
            $tested_map .= sprintf "%05X\t%s\n", $start, $invmap_ref->[$i];
        }

        # Finished creating the string from the inversion map.  Can compare
        # with what the file is.
        chomp $tested_map;
        if ($tested_map ne $official) {
            fail_with_diff($mod_prop, $official, $tested_map, "prop_invmap");
            next PROPERTY;
        }
        if (@code_point_in_names) {
            fail("prop_invmap('$mod_prop')");
            use Data::Dumper;
            diag("Missing code-point-in-name line(s)" . Dumper \@code_point_in_names);
            next PROPERTY;
        }
    }
    elsif ($format eq 's' || $format eq 'r') {

        # Here the map is not more or less directly from a file stored on
        # disk.  We try a different tack.  These should all be properties that
        # have just a few possible values (most of them are  binary).  We go
        # through the map list, sorting each range into buckets, one for each
        # map value.  Thus for binary properties there will be a bucket for Y
        # and one for N.  The buckets are inversion lists.  We compare each
        # constructed inversion list with what we would get for it using
        # prop_invlist(), which has already been tested.  If they all match,
        # the whole map must have matched.
        my %maps;
        my $previous_map;

        # (The extra -1 is to not look at the final element in the loop, which
        # we know is the one that starts just beyond Unicode and goes to
        # infinity.)
        for my $i (0 .. @$invlist_ref - 1 - 1) {
            my $range_start = $invlist_ref->[$i];

            # Because we are sorting into buckets, things could be
            # out-of-order here, and still be in the correct order in the
            # bucket, and hence wouldn't show up as an error; so have to
            # check.
            if (($i > 0 && $range_start <= $invlist_ref->[$i-1])
                || $range_start >= $invlist_ref->[$i+1])
            {
                fail("prop_invmap('$mod_prop')");
                diag(sprintf "Range beginning at %04X is out-of-order.", $invlist_ref->[$i]);
                next PROPERTY;
            }

            # This new range closes out the range started in the previous
            # iteration.
            push @{$maps{$previous_map}}, $range_start if defined $previous_map;

            # And starts a range which will be closed in the next iteration.
            $previous_map = $invmap_ref->[$i];
            push @{$maps{$previous_map}}, $range_start;
        }

        # The range we just started hasn't been closed, and we didn't look at
        # the final element of the loop.  If that range is for the default
        # value, it shouldn't be closed, as it is to extend to infinity.  But
        # otherwise, it should end at the final Unicode code point, and the
        # list that maps to the default value should have another element that
        # does go to infinity for every above Unicode code point.

        if (@$invlist_ref > 1) {
            my $penultimate_map = $invmap_ref->[-2];
            if ($penultimate_map ne $missing) {

                # The -1th element contains the first non-Unicode code point.
                push @{$maps{$penultimate_map}}, $invlist_ref->[-1];
                push @{$maps{$missing}}, $invlist_ref->[-1];
            }
        }

        # Here, we have the buckets (inversion lists) all constructed.  Go
        # through each and verify that matches what prop_invlist() returns.
        # We could use is_deeply() for the comparison, but would get multiple
        # messages for each $prop.
        foreach my $map (keys %maps) {
            my @off_invlist = prop_invlist("$prop = $map");
            my $min = (@off_invlist >= @{$maps{$map}})
                       ? @off_invlist
                       : @{$maps{$map}};
            for my $i (0 .. $min- 1) {
                if ($i > @off_invlist - 1) {
                    fail("prop_invmap('$mod_prop')");
                    diag("There is no element [$i] for $prop=$map from prop_invlist(), while [$i] in the implicit one constructed from prop_invmap() is '$maps{$map}[$i]'");
                    next PROPERTY;
                }
                elsif ($i > @{$maps{$map}} - 1) {
                    fail("prop_invmap('$mod_prop')");
                    diag("There is no element [$i] from the implicit $prop=$map constructed from prop_invmap(), while [$i] in the one from prop_invlist() is '$off_invlist[$i]'");
                    next PROPERTY;
                }
                elsif ($maps{$map}[$i] ne $off_invlist[$i]) {
                    fail("prop_invmap('$mod_prop')");
                    diag("Element [$i] of the implicit $prop=$map constructed from prop_invmap() is '$maps{$map}[$i]', and the one from prop_invlist() is '$off_invlist[$i]'");
                    next PROPERTY;
                }
            }
        }
    }
    else {  # Don't know this property nor format.

        fail("prop_invmap('$mod_prop')");
        diag("Unknown format '$format'");
    }

    pass("prop_invmap('$mod_prop')");
}

done_testing();
