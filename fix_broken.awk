BEGIN {
  state = 0;
  split(broken, p, ",");
  for (i in p) brokens[p[i]] = "";
} 

/[A-Za-z]/ {
  if ((state) && ($0 ~ /[A-Z]/)) printf(" ");
  if ($0 in brokens) {
    state = 1;
    ORS="";
  } else {
    state = 0;
    ORS="\n";
  }
  print $0;
}
