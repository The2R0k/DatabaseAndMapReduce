%%%-------------------------------------------------------------------
%%% @author ivan
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. окт. 2019 17:15
%%%-------------------------------------------------------------------
-module(map_reduce_reduce_step).
-author("ivan").

-behaviour(gen_server).

%% Supervisor
-export([
  start_link/1
]).

%% Gen Server API
-export([
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2
]).

%% API
-export([
  show_current_map/0,
  add_map_result/1
]).

-record(state, {
  version = "",
  process_count,
  output_to,
  map = #{}
}).

-record(attach, {
  data = #{}
}).

-record(show, {}).
%%%-------------------------------------------------------------------
%%% API
%%%-------------------------------------------------------------------

show_current_map() ->
  gen_server:call(?MODULE, #show{}).

add_map_result(Map) ->
  gen_server:cast(?MODULE, #attach{data = Map}).
%%%-------------------------------------------------------------------
%%% Supervisor API
%%%-------------------------------------------------------------------

start_link(Settings) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, Settings, []).
%%%-------------------------------------------------------------------
%%% Gen Server API
%%%-------------------------------------------------------------------

init(Settings) ->
  ProcessCount = proplists:get_value(process_count, Settings),
  OutputTo = proplists:get_value(output_to, Settings),
  State =
    #state{
      version = erlang:system_info(otp_release),
      process_count = ProcessCount,
      output_to = OutputTo
    },
  case ProcessCount > 0 of
    true -> {ok, State};
    false -> {stop, no_file}
  end.
%%%-------------------------------------------------------------------

handle_call(#show{}, _From, State) ->
  {reply, State#state.map, State};
handle_call(_, _, State) ->
  {reply, not_supported, State}.
%%%-------------------------------------------------------------------

handle_cast(#attach{data = NewData}, #state{version = Version} = State) ->
  Map =
    case Version > "20" of
      true ->
        map_reduce_utils:reduce(maps:next(maps:iterator(NewData)), State#state.map);
      false ->
        map_reduce_utils:reduce(maps:to_list(NewData), State#state.map)
    end,
  State2 =
    State#state{
      process_count = State#state.process_count - 1,
      map = Map
      },
  case State2#state.process_count of
    0 ->
      State2#state.output_to ! State2#state.map,
      {stop, normal, State2};
    _ ->
      {noreply, State2}
  end;
handle_cast(_, State) ->
  {noreply, State}.
%%%-------------------------------------------------------------------

handle_info(_, State) ->
  {norepply, State}.
%%%-------------------------------------------------------------------
%%% End
%%%-------------------------------------------------------------------
