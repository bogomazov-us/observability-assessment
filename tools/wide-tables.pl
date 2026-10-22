#!/usr/bin/perl -0777 -pi
# Marks HTML tables wider than six columns with class "wide", so the export style can set them
# on a landscape page (templates/stage-report.md, "Layout"). Used by scripts/build.sh and
# tools/report-pdf.sh on pandoc's HTML output.
s{<table(?![^>]*class="wide")([^>]*)>(.*?)</table>}{
  my ($attr, $body) = ($1, $2);
  my ($head) = $body =~ m{<tr[^>]*>(.*?)</tr>}s;
  my $cols = () = ($head // '') =~ m{<t[hd][\s>]}g;
  $cols > 6 ? qq{<table class="wide"$attr>$body</table>} : qq{<table$attr>$body</table>}
}gse;
