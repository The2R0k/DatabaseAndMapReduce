%%%-------------------------------------------------------------------
%%% @author ivan
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. окт. 2019 2:34
%%%-------------------------------------------------------------------
-module(db_manager).
-author("ivan").

-behaviour(gen_server).

%% Supervisor
-export([start_link/0]).

%% Gen Server API
-export([
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2
]).

%% Manager API
-export([
  new_base/1,
  get_tid_by_name/1,
  list_all_db/0
]).

-record(state, {
  db_list = []
}).

-record(data, {
  name,
  tid
}).

-record(add, {
  db_name
}).
-record(whereis, {
  db_name
}).
-record(list, {
}).

%%%-------------------------------------------------------------------
%%% Supervisor
%%%-------------------------------------------------------------------

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%%%-------------------------------------------------------------------
%%% API
%%%-------------------------------------------------------------------

new_base(DBName) ->
  gen_server:cast(?MODULE, #add{db_name = DBName}).

get_tid_by_name(DBName) ->
  gen_server:call(?MODULE, #whereis{db_name = DBName}).

list_all_db() ->
  gen_server:call(?MODULE, #list{}).
%%%-------------------------------------------------------------------
%%% Gen Server API
%%%-------------------------------------------------------------------

init(_Args) ->
  {ok, #state{}}.

handle_call(#list{}, _From, State) ->
  {reply, State#state.db_list, State};
handle_call(#whereis{db_name = DBName}, _From, State) ->
  Output = find(DBName, State),
  {reply, Output, State};
handle_call(Any, _From, State) ->
  {reply, {error, {bad_command, Any}}, State}.

handle_cast(#add{db_name = DBName}, State) ->
  State2 =
    case find(DBName, State) of
      {ok, _} ->
        State;
      _ ->
        TID = ets:new(?MODULE, [set, public]),
        State#state{db_list = [#data{name = DBName, tid = TID} | State#state.db_list]}
    end,
  {noreply, State2};
handle_cast(_, State) ->
  {noreply, State}.

handle_info(_, State) ->
  {noreply, State}.
%%%-------------------------------------------------------------------s
%%% Internal Functions
%%%-------------------------------------------------------------------

find(DBName, State) ->
  case lists:keyfind(DBName, #data.name, State#state.db_list) of
    false -> {error, not_found};
    #data{tid = TID} -> {ok, TID}
  end.
%%%-------------------------------------------------------------------
%%% End
%%%-------------------------------------------------------------------
