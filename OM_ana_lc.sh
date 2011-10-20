for i in $( ls F*EVLIST* ); do
  echo "rate"$i
  evselect table=$i timebinsize=100 rateset="rate"$i expression='(RAWX, RAWY) in annulus(1086.5,958,3,9)' maketimecolumn=true makeratecolumn=true
  #evselect table=$i timebinsize=100 rateset="rate"$i expression='(RAWX, RAWY) in box(1085.4688,956.84375,21.6875,22.6875,0)' maketimecolumn=true makeratecolumn=true withrateset=yes
done

