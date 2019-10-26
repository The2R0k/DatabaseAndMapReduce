%%%-------------------------------------------------------------------
%%% @author ivan
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. окт. 2019 5:14
%%%-------------------------------------------------------------------
-module(myapp).
-author("ivan").

%% API
-export([
  start/0,
  stop/0
]).

start() ->
  application:start(myapp).

stop() ->
  application:stop(myapp).
