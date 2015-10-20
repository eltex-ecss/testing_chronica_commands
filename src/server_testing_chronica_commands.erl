%%%-------------------------------------------------------------------
%%% -*- coding: utf-8 -*-
%%% @author Nikita Roshchupkin
%%% @copyright (C) 2015, Eltex, Novosibirsk, Russia
%%% @doc
%%%
%%% @end
%%% Created : 4 Oct 2015
%%%-------------------------------------------------------------------
-module(server_testing_chronica_commands).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
        terminate/2, code_change/3, start_link/0]).

-export([testing_rules/0, testing_flows/0, testing_formats/0]).
%%test
testing_rules() ->
    gen_server:call(?MODULE, testing_rule_all_messages),
    gen_server:call(?MODULE, testing_rule_only_info),
    gen_server:call(?MODULE, testing_rule_tag_begin_msg),
    gen_server:call(?MODULE, testing_rule_off).

testing_flows() ->
    gen_server:call(?MODULE, testing_flow_file),
    gen_server:call(?MODULE, testing_flow_console),
    gen_server:call(?MODULE, testing_flow_binary_file).

testing_formats() ->
    gen_server:call(?MODULE, testing_format_short),
    gen_server:call(?MODULE, testing_format_reverse_default),
    gen_server:call(?MODULE, testing_format_strange_default).

logs_check(Arg) ->
    log:debug("TEST 1 ~p", [Arg]),
    log:warning([info], "TEST 2 ~p", [Arg]),
    log:info([info], "TEST 3 ~p", [Arg]),
    log:info([msginfo], "TEST 4 ~p", [Arg]),
    log:error([msginfo], "TEST 5 ~p", [Arg]),
    log:error([msginfo, info], "end test~n~n", []).

%%gen_server callback
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("starting server for testing chronica commands ~n"),
    erlang:process_flag(trap_exit, true),
    {ok, 0}.

%%testing_rules()
handle_call(testing_rule_all_messages, _From, State) ->
    io:format("Данному правилу подходят все логи уровня info и ниже,"
        " запись в result_testing_rules.log, формат записи default~n"),
    io:format("rules, [{all_messeges,     \"*\",    info,  [result_testing_rules], on}]~n"),
    io:format("flows, [{result_testing_rules, [{file, \"result_testing_rules.log\"}]}]~n~n"),
    chronica_manager:update_rule_inwork(all_messeges, true),
    logs_check(testing_rule_all_messages),
    chronica_manager:update_rule_inwork(all_messeges, false),
    {reply, ok, State};

handle_call(testing_rule_only_info, _From, State) ->
    io:format("Данному правилу подходят логи только с тегом info,"
        " запись в result_testing_rules.log, формат записи default~n"),
    io:format("rules, [{only_info,     \"info\",    info,  [result_testing_rules], on}]~n"),
    io:format("flows, [{result_testing_rules, [{file, \"result_testing_rules.log\"}]}]~n~n"),
    chronica_manager:update_rule_inwork(only_info, true),
    logs_check(testing_rule_only_info),
    chronica_manager:update_rule_inwork(only_info, false),
    {reply, ok, State};

handle_call(testing_rule_tag_begin_msg, _From, State) ->
    io:format("Данному правилу подходят логи начинающиеся с msg,"
        " запись в result_testing_rules.log, формат записи default~n"),
    io:format("rules, [{tag_begin_msg,     \"msg*\",    info,  [result_testing_rules], on}]~n"),
    io:format("flows, [{result_testing_rules, [{file, \"result_testing_rules.log\"}]}]~n~n"),
    chronica_manager:update_rule_inwork(tag_begin_msg, true),
    logs_check(testing_rule_tag_begin_msg),
    chronica_manager:update_rule_inwork(tag_begin_msg, false),
    {reply, ok, State};

handle_call(testing_rule_off, _From, State) ->
    io:format("Проверка записи логов в файл или на консоль при выключенных правилах~n"),
    logs_check(testing_rule_off),
    {reply, ok, State};

%%testing_flows()
handle_call(testing_flow_file, _From, State) ->
    io:format("Данный поток записывает в file.log сообщения уровня debug,"
        " формат записи default~n"),
    io:format("rules, [{all_file,     \"*\",    debug,  [file], on}]~n"),
    io:format("flows, [{filez, [{file, \"file.log\"}]}],~n~n"),
    chronica_manager:update_rule_inwork(all_file, true),
    logs_check(filez),
    chronica_manager:update_rule_inwork(all_file, false),
    {reply, ok, State};

handle_call(testing_flow_console, _From, State) ->
    io:format("Данный поток выводит на консоль сообщения уровня debug,"
        " формат записи default~n"),
    io:format("rules, [{all_console,     \"*\",    debug,  [console], on}]~n"),
    io:format("flows, [{screen, [{tty, default}]}],~n~n"),
    chronica_manager:update_rule_inwork(all_console, true),
    logs_check(console),
    chronica_manager:update_rule_inwork(all_console, false),
    {reply, ok, State};

handle_call(testing_flow_binary_file, _From, State) ->
    io:format("Данный поток записывает в binary_file.log сообщения уровня debug"
        " в виде бинарных данных, формат записи default~n"),
    io:format("rules, [{all_binary_file,     \"*\",    debug,  [binary_file], on}]~n"),
    io:format("flows, [{binary_file, [{file, \"binary_file.log\", binary}]}]~n~n"),
    chronica_manager:update_rule_inwork(all_binary_file, true),
    logs_check(binary_file),
    chronica_manager:update_rule_inwork(all_binary_file, false),
    {reply, ok, State};

%%testing_formats()
handle_call(testing_format_short, _From, State) ->
    io:format("Данный поток записывает в file_short.log сообщения уровня debug,"
        " формат записи short~n"),
    io:format("rules, [{all_file_short,     \"*\",    debug,  [file_short], on}]~n"),
    io:format("flows, [{file_short, [{file, \"file_short.log\", short}]}],~n"),
    io:format("formats, [{short, \"%H:%Mi:%S.%Ms [%Priority] %Message\"}]~n~n"),
    chronica_manager:update_rule_inwork(all_file_short, true),
    logs_check(file_short),
    chronica_manager:update_rule_inwork(all_file_short, false),
    {reply, ok, State};

handle_call(testing_format_reverse_default, _From, State) ->
    io:format("Данный поток записывает в file_reverse_default.log сообщения уровня debug,"
        " формат записи reverse_default~n"),
    io:format("rules, [{all_reverse_default,     \"*\",    debug,  [file_reverse_default], on}]~n"),
    io:format("flows, [{file_reverse_default, [{file, \"file_reverse_default.log\", reverse_default}]}]~n"),
    io:format("formats, [{reverse_default, \"%Message %Pid[%Module:%Function:%Line]: %PRIORITY %Y-%M-%D %H:%Mi:%S.%Ms\"}]~n~n"),
    chronica_manager:update_rule_inwork(all_reverse_default, true),
    logs_check(file_reverse_default),
    chronica_manager:update_rule_inwork(all_reverse_default, false),
    {reply, ok, State};

handle_call(testing_format_strange_default, _From, State) ->
    io:format("Данный поток записывает в file_strange_default.log сообщения уровня debug,"
        " формат записи file_strange_default~n"),
    io:format("rules, [{all_strange_default,     \"*\",    debug,  [file_strange_default], on}]~n"),
    io:format("flows, [{file_strange_default, [{file, \"file_strange_default.log\", strange_default}]}]~n"),
    io:format("formats, [{strange_default, \"%PRIORITY %Message %Y-%M-%D %H:%Mi:%S.%Ms %Function\"}]~n~n"),
    chronica_manager:update_rule_inwork(all_strange_default, true),
    logs_check(file_strange_default),
    chronica_manager:update_rule_inwork(all_strange_default, false),
    {reply, ok, State}.

handle_cast(_Msg, N)  -> {noreply, N}.

handle_info(_Info, State)  -> {noreply, State}.

terminate(_Reason, _State) ->
    io:format("stopping server for testing chronica commands ~n"),
    ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.