#!/usr/bin/perl -0777 -pi
# SPDX-License-Identifier: Apache-2.0
# Post-processes pandoc's HTML before the PDF is set (scripts/build.sh, tools/report-pdf.sh):
# - tables wider than six columns get class "wide", which the export style sets landscape;
# - stable ids (L-07, E-301, OQ4-1, REC-012 …) are kept on one line, so a narrow column cannot
#   break them at the hyphen and a text search of the PDF still finds them; so is a short code
#   token such as a commit hash, which a cell would otherwise break character by character.
s{<table(?![^>]*class="wide")([^>]*)>(.*?)</table>}{
  my ($attr, $body) = ($1, $2);
  my ($head) = $body =~ m{<tr[^>]*>(.*?)</tr>}s;
  my $cols = () = ($head // '') =~ m{<t[hd][\s>]}g;
  # A two-column table with an empty header is a list of labels and values ("Checked", "Main
  # limits"): its label column keeps its words whole.
  my $kv = $cols == 2 && ($head // '') !~ m{<th[^>]*>\s*[^<\s]};
  $cols > 6 ? qq{<table class="wide"$attr>$body</table>}
    : $kv ? qq{<table class="kv"$attr>$body</table>} : qq{<table$attr>$body</table>}
}gse;
s{>([^<]+)<}{
  my $t = $1;
  $t =~ s{\b((?:[A-Z]{1,3}\d?)-\d{1,4}(?:\.\d+)?)\b}{<span class="id">$1</span>}g;
  ">$t<"
}ge;
s{<code>([^<\s]{1,16})</code>}{<code class="id">$1</code>}g;
