%% -*-erlang-*-
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
%%%   Google's Protocol Buffers Library parser.
%%% @end
%%%
%% @author Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%% @copyright (C) 2013, Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%%%-------------------------------------------------------------------

%% ===================================================================
%% Nonterminals.
%% ===================================================================
Nonterminals
statements statement
message message_parts
fields field field_options label tag type
options option option_body
enum enum_field option_enum_field
service option_rpc import package rpc
extend extensions  extension extension_star
%% Bloody group adds 13 shift/reduce conflicts and then up to 85 now 98
group
identifier b_identifier h_identifier
constant
uninterpreted
.

%% ===================================================================
%% Terminals.
%% ===================================================================
Terminals
t_message t_enum t_option
t_import t_public
t_service t_package t_extend t_group t_extensions t_to t_max t_rpc t_returns
t_identifier
t_required t_optional t_repeated
c_integer c_float c_bool c_string
t_dot
t_garbage
%% Symbols
'{' '}' '(' ')' '[' ']' '=' ';' ','
.

%% ===================================================================
%% Expected shit/reduce conflicts.
%% ===================================================================
Expect 114.

%% ===================================================================
%% Rootsymbol.
%% ===================================================================
Rootsymbol statements.

%% ===================================================================
%% Rules.
%% ===================================================================

statements -> '$empty' : [].
statements -> ';' statements : [].
statements -> statement statements : add('$1', '$2').

statement -> message : '$1'.
statement -> enum : '$1'.
statement -> service.
statement -> extend.
statement -> import.
statement -> package.
statement -> option.

message -> t_message identifier '{' message_parts '}' : [].
%%           #message{name = $2, body = '$4'}.

import -> t_import c_string ';'.
import -> t_import t_public c_string ';'.

identifier -> b_identifier h_identifier.
identifier -> t_dot identifier h_identifier.
identifier -> '(' identifier ')' h_identifier.

h_identifier -> '$empty'.
h_identifier ->  t_dot identifier h_identifier.

b_identifier -> t_identifier.
b_identifier -> t_message : token(b_identifier, '$1').
b_identifier -> t_enum : token(b_identifier, '$1').
b_identifier -> t_option : token(b_identifier, '$1').
b_identifier -> t_required : token(b_identifier, '$1').
b_identifier -> t_optional : token(b_identifier, '$1').
b_identifier -> t_repeated : token(b_identifier, '$1').
b_identifier -> t_extend : token(b_identifier, '$1').
b_identifier -> t_group : token(b_identifier, '$1').
b_identifier -> t_extensions : token(b_identifier, '$1').
b_identifier -> t_package : token(b_identifier, '$1').
b_identifier -> t_service : token(b_identifier, '$1').

label -> t_required : token(label, '$1').
label -> t_optional : token(label, '$1').
label -> t_repeated : token(label, '$1').

tag -> c_integer.

message_parts -> '$empty' : [].
%% generated 10 more shift/reduce.
message_parts ->';' message_parts : [].
message_parts -> message message_parts : add('$1', '$2').
message_parts -> enum message_parts : add('$1', '$2').
message_parts -> extensions message_parts : add('$1', '$2').
message_parts -> extend message_parts : add('$1', '$2').
message_parts -> option message_parts : add('$1', '$2').
message_parts -> field message_parts : add('$1', '$2').
message_parts -> group message_parts : add('$1', '$2').

group -> label t_group identifier '=' c_integer message_parts.


enum -> t_enum identifier '{' option_enum_field '}'.

option_enum_field -> '$empty'.
option_enum_field -> option option_enum_field.
option_enum_field -> enum_field option_enum_field.

enum_field -> identifier '=' c_integer ';'.
enum_field -> identifier '=' c_integer '[' option_body ']' ';'.

field -> label type identifier '=' tag ';'.
field -> label type identifier '=' tag '[' option_body  field_options ']' ';'.
field -> label t_group identifier '=' tag '{' fields '}'.


field_options -> '$empty'.
field_options -> ',' option_body field_options.

options -> '$empty'.
options -> option options.

option -> t_option option_body ';'.

uninterpreted -> '$empty'.
uninterpreted -> '{' uninterpreted '}' uninterpreted.
uninterpreted -> t_identifier uninterpreted.
uninterpreted -> c_integer uninterpreted.
uninterpreted -> c_float uninterpreted.
uninterpreted -> c_bool uninterpreted.
uninterpreted -> c_string uninterpreted.
uninterpreted -> t_dot uninterpreted.
uninterpreted -> '(' uninterpreted.
uninterpreted -> ')' uninterpreted.
uninterpreted -> '[' uninterpreted.
uninterpreted -> ']' uninterpreted.
uninterpreted -> '=' uninterpreted.
uninterpreted -> ';' uninterpreted.
uninterpreted -> ',' uninterpreted.
uninterpreted -> t_garbage uninterpreted.

%% option_body -> '(' identifier ')' '=' constant.
option_body -> identifier '=' constant.
option_body -> identifier '=' '{' uninterpreted '}'.

constant -> t_identifier.
constant -> c_integer.
constant -> c_float.
constant -> c_string.
constant -> c_bool.

type -> identifier.

package -> t_package identifier ';'.

extend -> t_extend identifier '{' fields '}'.
extend -> t_extend identifier '{' group '}'.

fields -> '$empty'.
fields -> ';'.
fields -> field fields.

service -> t_service identifier '{' option_rpc '}'.

option_rpc -> '$empty'.
option_rpc -> option option_rpc.
option_rpc -> rpc option_rpc.

%% rpc -> t_rpc identifier '(' identifier ')' t_returns '(' identifier ')' ';'.
rpc -> t_rpc identifier identifier t_returns identifier ';'.
rpc -> t_rpc identifier identifier t_returns identifier '{' options '}'.

extensions -> t_extensions extension extension_star ';'.

extension_star -> '$empty'.
extension_star -> ',' extension extension_star.

extension -> c_integer.
extension -> c_integer t_to c_integer.
extension -> c_integer t_to t_max.


%% ===================================================================
%% Erlang Code.
%% ===================================================================
Erlang code.

%% Includes
-include_lib("protobuf/include/proto.hrl").

%% API
-export([file/1]).

%%====================================================================
%% API
%%====================================================================

%%--------------------------------------------------------------------
%% Function: file(FileName) -> Proto.
%% @doc
%%   Parses a .proto file.
%% @end
%%--------------------------------------------------------------------
-spec file(string()) -> [_].
%%--------------------------------------------------------------------
file(File) ->
    {ok, Proto} = parse(protobuf_scan:file(File)),
    Proto.

%%====================================================================
%% Internal functions
%%====================================================================

token(NewType, {_, Line, Value}) -> {NewType, Line, Value}.

add([], T) -> T;
add(H, T) -> [H | T].
