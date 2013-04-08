%%==============================================================================
%% Copyright 2013 Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%==============================================================================

%%%-------------------------------------------------------------------
%%% @doc
%%%   eunit unit tests for protobuf_parse parser.
%%% @end
%%%
%% @author Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%% @copyright (C) 2013, Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%%%-------------------------------------------------------------------
-module(parse_tests).
-copyright('Jan Henry Nystrom <JanHenryNystrom@gmail.com>').

%% Includes
-include_lib("eunit/include/eunit.hrl").

%% ===================================================================
%% Tests.
%% ===================================================================

%%%-------------------------------------------------------------------
% Distro
%%%-------------------------------------------------------------------
parse_distro_test_() ->
    [?_test(?assertEqual(true, is_list(protobuf_parse:file(File)))) ||
        File <- files(distro)].


%% ===================================================================
%% Internal functions.
%% ===================================================================

files(distro) ->
    Dir = filename:join([code:lib_dir(protobuf), "test", "protos", "distro"]),
    {ok, Files} = file:list_dir(Dir),
    [filename:join([Dir, File]) ||
        File <- Files,
        filename:extension(File) == ".proto"].
