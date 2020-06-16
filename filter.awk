BEGIN {
  problem = "Nagar"
  split(problem, p, " ")
  for (i in p) problems[p[i]] = ""
} 

/[A-Za-z]/ {
  second = $0
  if (second in problems) {
    printf("%s %s\n", first, second)
    first = second
    next
  }
  if (first && !(first in problems)) {
    print first
  }
  first = second
}

END {
  print second
}
