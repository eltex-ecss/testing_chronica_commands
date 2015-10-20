%%%-------------------------------------------------------------------
%%% -*- coding: utf-8 -*-
%%% @author Nikita Roshchupkin
%%% @copyright (C) 2015, Eltex, Novosibirsk, Russia
%%% @doc
%%%
%%% @end
%%% Created : 4 Oct 2015
%%%-------------------------------------------------------------------
-module(server_testing_chronica_commands_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, StartArgs) ->
    testing_supervisor:start_link(StartArgs).

stop(_State) ->
    ok.