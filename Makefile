compile:
	rebar compile

get-deps:
	rebar g-d

del-deps:
	rm -rf deps

run:
	erl -pa ebin deps/*/ebin -s myapp
build-and-run:
	rebar g-d
	rebar compile
	erl -pa ebin deps/*/ebin -s myapp
