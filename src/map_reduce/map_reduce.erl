%%%-------------------------------------------------------------------
%%% @author ivan
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%     Тестовое задание №2.
%%%
%%% @end
%%% Created : 25. окт. 2019 6:16
%%%-------------------------------------------------------------------
-module(map_reduce).
-author("ivan").

%% API
-export([
  start/1
]).

%%%-------------------------------------------------------------------
%%% API
%%%-------------------------------------------------------------------

start([]) -> #{};
start(FilesList) ->
  ProcessCount = erlang:length(FilesList),
  map_reduce_reduce_step:start_link([{process_count, ProcessCount}, {output_to, self()}]),
  [erlang:spawn(map_reduce_map_step, make_map, [FileName]) || FileName <- FilesList],
  receive
    Result -> Result
  end.
%%%-------------------------------------------------------------------
%%% End
%%%-------------------------------------------------------------------
