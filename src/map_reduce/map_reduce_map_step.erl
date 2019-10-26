%%%-------------------------------------------------------------------
%%% @author ivan
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. окт. 2019 17:15
%%%-------------------------------------------------------------------
-module(map_reduce_map_step).
-author("ivan").

%% API
-export([
  make_map/1
]).

%%%-------------------------------------------------------------------
%%% API
%%%-------------------------------------------------------------------

make_map(Filename) ->
  Map =
    case file:open(Filename, [read]) of
      {ok, Descriptor} ->
        read(Descriptor, file:read_line(Descriptor), maps:new());
      _ ->
        maps:new()
    end,
  map_reduce_reduce_step:add_map_result(Map).
%%%-------------------------------------------------------------------
%%% Internal Functions
%%%-------------------------------------------------------------------

read(Descriptor, eof, Acc) ->
  file:close(Descriptor),
  Acc;
read(Descriptor, {ok, String}, Acc) ->
  WordsList = string:tokens(String, "\t\n\r "),
  Acc2 = map_reduce_utils:attach_words_to_map(WordsList, Acc),
  read(Descriptor, file:read_line(Descriptor), Acc2).
%%%-------------------------------------------------------------------
%%% End
%%%-------------------------------------------------------------------
