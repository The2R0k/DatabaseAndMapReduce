%%%-------------------------------------------------------------------
%%% @author ivan
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. окт. 2019 18:34
%%%-------------------------------------------------------------------
-module(map_reduce_utils).
-author("ivan").

%% API
-export([
  reduce/2,
  attach_words_to_map/2
]).

%%%-------------------------------------------------------------------
%%% API
%%%-------------------------------------------------------------------

% OTP version 20
reduce([], Acc) -> Acc;
reduce([{Key, Value} | Tail], Acc) ->
  AttachFun =
    fun (OldValue) ->
      OldValue + Value
    end,
  reduce(Tail, maps:update_with(Key, AttachFun, Value, Acc));

% OTP Version 21+
reduce(none, Acc) -> Acc;
reduce({Key, Value, Iterator}, Acc) ->
  AttachFun =
    fun (OldValue) ->
      OldValue + Value
    end,
  reduce(maps:next(Iterator), maps:update_with(Key, AttachFun, Value, Acc));
reduce(Map, Acc) when is_map(Map) ->
  Iterator = maps:iterator(Map),
  reduce(maps:next(Iterator), Acc).
%%%-------------------------------------------------------------------

attach_words_to_map([], Acc) -> Acc;
attach_words_to_map([Word | Tail], Acc) ->
  AttachFun =
    fun (OldValue) ->
      OldValue + 1
    end,
  attach_words_to_map(Tail, maps:update_with(Word, AttachFun, 1, Acc)).
%%%-------------------------------------------------------------------
%%% End
%%%-------------------------------------------------------------------
