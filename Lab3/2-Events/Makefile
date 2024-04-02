file = events

$(file): $(file).pl
	swipl -q -O -g main --stand_alone=true -o $(file) -c $(file).pl

eventsSol: eventsSol.pl
	swipl -q -O -g main --stand_alone=true -o eventsSol -c eventsSol.pl

.PHONY: clean realclean

clean:
	-rm -f clauses header infile.cnf model

realclean: clean
	-rm -f $(file)

run: $(file)
	./$(file) eventsInput1.pl > output.txt