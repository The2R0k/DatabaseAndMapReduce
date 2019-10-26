%%%-------------------------------------------------------------------
%%% @author ivan
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%     Тестовое задание №1.
%%%     Проверки на соответствия входных данных спекам отсутствует т.к.:
%%%       1) для внутренней логики моей DB это не имеет значение
%%%       2) мы считаем что программист соблюдает протоколы
%%%       3) в тз говорилось об определенных ошибках, ошибка формата
%%%          не входит в их число
%%%     Также, отмечу, что для функционирования данного API необходим
%%%     запущенный db_manager. Для запуска db_manager достаточно выполнить
%%%     функцию db_manager:start_link(). Либо при
%%%     Что-бы проверить количество открытых db (db:new()), можно воспользоваться
%%%     функцией db_manager:list_all_db().
%%% @end
%%% Created : 25. окт. 2019 1:49
%%%-------------------------------------------------------------------
-module(db).
-author("ivan").

%% API
-export([
  new/1,
  create/2,
  read/2,
  update/2,
  delete/2
]).

-type data_record() :: {Key :: integer(), UserName :: string(), City :: string()}.

%%%-------------------------------------------------------------------
%%% API
%%%-------------------------------------------------------------------

-spec new(DBName :: string()) ->
  ok.

new(DBName) ->
  db_manager:new_base(DBName),
  ok.
%%%-------------------------------------------------------------------

-spec create(Record :: data_record(), DBName :: string()) ->
  {ok, Record :: data_record()} | {error, Reason :: term()}.

create({_, _, _} = Record, DBName) ->
  TID = get_tid(DBName),
  case ets:insert_new(TID, Record) of
    true -> {ok, Record};
    false -> throw({error, already_exists})
  end;
create(_, _) ->
  throw({error, bad_format}).
%%%-------------------------------------------------------------------

-spec read(Key :: integer(), DBName :: string()) ->
  {ok, Record :: data_record()} | {error, Reason :: term()}.

read(Key, DBName) ->
  TID = get_tid(DBName),
  case ets:lookup(TID, Key) of
    [] -> throw({error, not_found});
    [Record] -> {ok, Record}
  end.
%%%-------------------------------------------------------------------

-spec update(Record :: data_record(), DBName :: string()) ->
  {ok, Record :: data_record()} | {error, Reason :: term()}.

update({Key, _, _} = Record, DBName) ->
  TID = get_tid(DBName),
  case ets:member(TID, Key) of
    true ->
      ets:insert(TID, Record),
      {ok, Record};
    false ->
      throw({error, not_found})
  end;
update(_, _) ->
  throw({error, bad_format}).
%%%-------------------------------------------------------------------

-spec delete(Key :: integer(), DBName :: string()) ->
  ok | {error, Reason :: term()}.

delete(Key, DBName) ->
  TID = get_tid(DBName),
  case ets:member(TID, Key) of
    true ->
      ets:delete(TID, Key),
      ok;
    false ->
      throw({error, not_found})
  end.
%%%-------------------------------------------------------------------
%%% Internal Functions
%%%-------------------------------------------------------------------

get_tid(DBName) ->
  case db_manager:get_tid_by_name(DBName) of
    {ok, TID} -> TID;
    Error -> throw(Error)
  end.
%%%-------------------------------------------------------------------
%%% End
%%%-------------------------------------------------------------------
