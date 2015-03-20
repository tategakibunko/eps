EXE:=eps.exe
PKGS:=pcre
SRCS:=	types.ml\
	utils.ml\
	parser.mli\
	parser.ml\
	lexer.ml\
	emit.ml\
	main.ml\

all:eps.exe

parser.ml:parser.mly
	ocamlyacc $<

lexer.ml:lexer.mll
	ocamllex $<

eps.exe:$(SRCS)
	ocamlfind ocamlopt -g -o $@ -linkpkg -package $(PKGS) $(SRCS)

clean:
	rm -f *.cmi *.cmx *.o *.a *.exe

rebuild:
	make clean
	make
