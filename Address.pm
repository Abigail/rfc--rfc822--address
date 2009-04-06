package RFC::RFC822::Address;

#
# $Id: Address.pm,v 1.5 2000/08/29 22:15:01 abigail Exp abigail $
#
# $Log: Address.pm,v $
# Revision 1.5  2000/08/29 22:15:01  abigail
# Changed group rule to make <leftop> part greedy.
#   (Damian Conway/Douglas Wilson)
# Added a test; removed $DEBUG part, now prints message on failures.
# Changed wording of license (using BSD/X style).
#
# Revision 1.4  1999/10/04 09:12:58  abigail
# Fixed typo in pod.
#
# Revision 1.3  1999/10/04 09:07:23  abigail
# Parsing of comments.
# Completed (?) test suite. Added --debug option to test.pl, to print
#    what was being matched, and what the result of validation was.
# Changed package name to RFC::RFC822::Address, to cope for 5.004 users;
#    MacPerl is still on 5.004.
#
# Revision 1.2  1999/10/02 10:08:48  abigail
# Grammar is now aware of the whitespace rules.
# Comment rules still have to be implemented.
# used h2xs.
# Created initial test.pl file.
#
# Revision 1.1  1999/10/01 08:50:13  abigail
# Initial revision
#
#

use strict;
use Exporter;
use Parse::RecDescent;

use vars qw /@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION/;

@ISA         = qw /Exporter/;
@EXPORT      = qw //;
@EXPORT_OK   = qw /valid/;
%EXPORT_TAGS = ();

($VERSION)   = '$Revision: 1.5 $' =~ /([\d.]+)/;

my $CRLF     = '\x0D\x0A';
$Parse::RecDescent::skip = "((?:$CRLF)?[ \t])*";
local $/;

# Now, pay attention. There are only 2 important lines of Perl in this
# module, and they follow now. ;-)
my $parser = Parse::RecDescent -> new (<DATA>) or die "Compilation error.\n";
sub valid ($) {$parser -> valid (shift)}

# That's it. The rest is just data....

<<'=cut'

=pod

=head1 NAME

RFC::RFC822::Address  --  RFC 822 style address validation.

=head1 SYNOPSIS

    use RFC::RFC822::Address qw /valid/;

    print "Valid\n" if valid 'abigail@example.com';

=head1 DESCRIPTION

This module checks strings to see whether they are have the valid
syntax, as defined in RFC 822 [1]. One subroutine, C<valid>, can
be imported, which takes a single string as argument. If the string
is valid according to RFC 822, a true value is returned, else a
false value is returned.

=head1 REFERENCES

=over 4

=item [1]

David H. Crocker (revisor): "STANDARD FOR THE FORMAT OF ARPA INTERNET
TEXT MESSAGES". RFC 822. 13 August 1982.

=back

=head1 CAVEATS and BUGS

This module sets the variable C<$Parse::RecDescent::skip>. This will
influence all other C<Parse::RecDescent> parsers. And this parser will
break if you set C<$Parse::RecDescent::skip> to another value. It doesn't
look that it is possible to set an alternative skip value for each parser,
other than setting the skip value on each production.

Example A.1.5 in RFC 822 is wrong. It should use
I<S<"Galloping Gourmet"@ANT.Down-Under>>.

This module should have been named C<RFC::822::Address>. However, perl
5.004 doesn't like the C<822> part, and at the time of this writing 
MacPerl is still at 5.004.

This module is slow.

=head1 REVISION HISTORY

    $Log: Address.pm,v $
    Revision 1.5  2000/08/29 22:15:01  abigail
    Changed group rule to make <leftop> part greedy.
      (Damian Conway/Douglas Wilson)
    Added a test; removed $DEBUG part, now prints message on failures.
    Changed wording of license (using BSD/X style).

    Revision 1.4  1999/10/04 09:12:58  abigail
    Fixed typo in pod.

    Revision 1.3  1999/10/04 09:07:23  abigail
    Parsing of comments.
    Completed (?) test suite. Added --debug option to test.pl, to print
       what was being matched, and what the result of validation was.
    Changed package name to RFC::RFC822::Address, to cope for 5.004 users;
       MacPerl is still on 5.004.

    Revision 1.2  1999/10/02 10:08:48  abigail
    Grammar is now aware of the whitespace rules.
    Comment rules still have to be implemented.
    used h2xs.
    Created initial test.pl file.

    Revision 1.1  1999/10/01 08:50:13  abigail
    Initial revision


=head1 AUTHOR

This package was written by Abigail, abigail@foad.org.

=head1 COPYRIGHT and LICENSE

This program is copyright 1999, 2000 by Abigail.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=cut

__DATA__

HTAB:         /\x09/                             # ASCII Horizontal tab
LF:           /\x0A/                             # ASCII Linefeed
CR:           /\x0D/                             # ASCII Carriage return
SPACE:        ' '                                # ASCII space
AT:           '@'                                # ASCII AT

LWSP_char:    SPACE | HTAB                       # Semantics = SPACE
CHAR:         /[\x00-\x7F]/                      # Any ASCII character.
CTL:          /[\x00-\x1F\x7F]/                  # Any ASCII control character
                                                 # and DEL
special:      /[]()<>@,;:\\".[]/                 # Must be in quoted string
                                                 # to be use within word.
CRLF:         <skip: ""> CR LF

linear_white_space:                              # Semantics = SPACE
              <skip: "">                         # CRLF => folding
              (CRLF(?) LWSP_char)(s)


atom:         /[^]\x00-\x20 \x7F\x80-\xFF()<>@,;:\\".[]+/
                                                 # Any CHAR except specials,
                                                 # SPACE and CTLs
              # Added '+' to regex in [cdq]text
              # for efficiency reasons.
ctext:        /[^)\\\x0D\x80-\xFF(]+/            # Any CHAR, excepting [, ], \,
           |  linear_white_space                 # and CR, and including
                                                 # linear-white-space =>
                                                 # may be folded
dtext:        /[^]\\\x0D\x80-\xFF[]+/            # Any CHAR, excepting [, ], \,
           |  linear_white_space                 # and CR, and including
                                                 # linear-white-space =>
                                                 # may be folded
qtext:        /[^"\\\x0D\x80-\xFF]+/             # Any CHAR, excepting ", \,
           |  linear_white_space                 # and CR, and including
                                                 # linear-white-space =>
                                                 # may be folded
quoted_pair:  '\\' <skip: ""> CHAR               # May quote any char


quoted_string:                                   # Regular qtext or quoted chars
              '"' <skip: ""> (qtext | quoted_pair)(s?) '"'
domain_literal:
              '[' <skip: ""> (dtext | quoted_pair)(s?) ']'
comment:      '(' <skip: ""> (ctext | quoted_pair | comment)(s?) ')'
                                                 # May be folded.
ocms:         comment(s?)                        # To keep grammar more
                                                 # readable. Not in RFC.


word:         atom
           |  quoted_string
phrase:       <leftop: word ocms word>           # sequence of words


valid:        ocms address ocms /^\Z/ {1}

address:      mailbox                            # one addressee
           |  group                              # named list

group:        phrase ocms ':' ocms
              <leftop: mailbox (ocms ',' ocms) mailbox>(s?)
              ocms ';'

mailbox:      addr_spec                          # simple address
           |  phrase ocms route_addr             # name & addr-spec

route_addr:   '<' ocms route(?) ocms addr_spec ocms '>'

route:        <leftop: (AT ocms domain)          # path-relative
                        (ocms ',' ocms)
                       (AT ocms domain)> ocms ':'

addr_spec:    local_part ocms '@' ocms domain    # global address

local_part:   <leftop: word (ocms '.' ocms) word>
                                                 # uninterpreted
                                                 # case-preserved

domain:       <leftop: sub_domain (ocms '.' ocms) sub_domain>

sub_domain:   domain_ref
           |  domain_literal

domain_ref:   atom                               # symbolic reference
