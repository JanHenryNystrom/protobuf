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
t_integer t_float t_bool t_string
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
statement -> service : '$1'.
statement -> extend : '$1'.
statement -> import : '$1'.
statement -> package : '$1'.
statement -> option : '$1'.

message -> t_message identifier '{' message_parts '}' :
           #message{name = '$2', body = '$4'}.

import -> t_import t_string ';' : #import{string = '$2'}.
import -> t_import t_public t_string ';' :
          #import{string = '$2', public = true}.

identifier -> b_identifier h_identifier : add('$1', '$2').
identifier -> t_dot identifier h_identifier : add('$2', '$3').
identifier -> '(' identifier ')' h_identifier : add({'$2'}, '$4').

h_identifier -> '$empty' : [].
h_identifier ->  t_dot identifier h_identifier : add('$2', '$3').

b_identifier -> t_identifier : '$1'.
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

tag -> t_integer : '$1'.

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

group -> label t_group identifier '=' tag message_parts :
         #group{label = '$1', name = '$3', tag = '$5', parts = '$6'}.

enum -> t_enum identifier '{' option_enum_field '}'.

option_enum_field -> '$empty'.
option_enum_field -> option option_enum_field.
option_enum_field -> enum_field option_enum_field.

enum_field -> identifier '=' t_integer ';'.
enum_field -> identifier '=' t_integer '[' option_body ']' ';'.

field -> label type identifier '=' tag ';' :
         #field{label = '$1', type = '$2', name = '$3', tag = '$5'}.
field -> label type identifier '=' tag '[' option_body  field_options ']' ';' :
         #field{label = '$1', type = '$2', name = '$3', tag = '$5',
                options = ['$7' | '$8']}.
field -> label t_group identifier '=' tag '{' fields '}' :
         #group{label = '$1', name = '$3', tag = '$5', parts = '$7'}.

field_options -> '$empty' : [].
field_options -> ',' option_body field_options : ['$2' | '$3'].

options -> '$empty' : [].
options -> option options : ['$1' | '$2'].

option -> t_option option_body ';' : '$2'.

uninterpreted -> '$empty'.
uninterpreted -> '{' uninterpreted '}' uninterpreted.
uninterpreted -> t_identifier uninterpreted.
uninterpreted -> t_integer uninterpreted.
uninterpreted -> t_float uninterpreted.
uninterpreted -> t_bool uninterpreted.
uninterpreted -> t_string uninterpreted.
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
option_body -> identifier '=' constant : #option{name = '$1', value = '$3'}.
option_body -> identifier '=' '{' uninterpreted '}' : #option{name = '$1'}.

constant -> t_identifier : '$1'.
constant -> t_integer : '$1'.
constant -> t_float : '$1'.
constant -> t_string : '$1'.
constant -> t_bool : '$1'.

type -> identifier : '$1'.

package -> t_package identifier ';' : #package{name = '$2'}.

extend -> t_extend identifier '{' fields '}' :
          #extend{name = '$2', fields = '$4'}.
extend -> t_extend identifier '{' group '}' :
          #extend{name = '$2', group = '$4'}.

fields -> '$empty' : [].
fields -> ';' : [].
fields -> field fields : add('$1', '$2').

service -> t_service identifier '{' option_rpc '}' :
           #service{name = '$2', option_rpc = '$4'}.

option_rpc -> '$empty' : [].
option_rpc -> option option_rpc : ['$1' | '$2'].
option_rpc -> rpc option_rpc : ['$1' | '$2'].

%% rpc -> t_rpc identifier '(' identifier ')' t_returns '(' identifier ')' ';'.
rpc -> t_rpc identifier identifier t_returns identifier ';' :
       #rpc{name = '$2', arg = '$3', return = '$5'}.
rpc -> t_rpc identifier identifier t_returns identifier '{' options '}' :
       #rpc{name = '$2', arg = '$3', return = '$5', options = '$7'}.

extensions -> t_extensions extension extension_star ';' : ['$2' | '$3'].

extension_star -> '$empty' : [].
extension_star -> ',' extension extension_star : ['$2' | '$3'].

extension -> t_integer : #extension{from = '$1'}.
extension -> t_integer t_to t_integer : #extension{from = '$1', to = '$3'}.
extension -> t_integer t_to t_max : #extension{from = '$1', to = max}.


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
