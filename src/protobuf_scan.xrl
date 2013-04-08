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
%%%   Google's Protocol Buffers Library lexer.
%%% @end
%%%
%% @author Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%% @copyright (C) 2013, Jan Henry Nystrom <JanHenryNystrom@gmail.com>
%%%-------------------------------------------------------------------

%% ===================================================================
%% Definitions.
%% ===================================================================
Definitions.

Whitespace = [\s\n\t\r\v\f]
WhitespaceNoNewline = [\s\n\t\r\v\f]
Unprintable = [\x01-\x1F]
Digit = [0-9]
OctalDigit = [0-7]
HexDigit = [0-9A-Fa-f]
Letter = [A-Za-z_]
Alphanumeric = [A-Za-z_0-9]
Escape = [abfnrtv\\\?\'\"]
Symbol = [;\{\}\)\(=\,\[\]]
Dot = \.

BLOCK_COMMENT = (/\*([^*]|[\s\t\r\n]|(\*+([^*/]|[\s\t\r\n])))*\*+/)|(//.*)
LINE_COMMENT = (#[^\n]*)|(////[^\n]*)

Identifier = {Letter}{Alphanumeric}*
DecInt = [-]?[1-9]{Digit}*
HexInt = [-]?0[xX]{HexDigit}+
OctInt = [-]?0{OctalDigit}*

Exp = ([Ee][+-]?[0-9]+)
Frac = (\.[0-9]*)
Float = [-]?[0-9]+(({Frac}{Exp}?)|{Exp})|nan|[+-]?inf

String = (\"([\\\\"]|[^\"\n])*\")|(\'([\\\\']|[^\'\n])*\')
%% "

Garbage = [^\s\n\t\r\v\f\x01-\x1F0-9A-Za-z_;\{\}\)\(=\,\[\]\-\+\.\\\"\']+

%% ===================================================================
%% Erlang code.
%% ===================================================================
Rules.

{Whitespace} : skip_token.
{BLOCK_COMMENT} : skip_token.
{LINE_COMMENT} : skip_token.
{Unprintable} : skip_token.

{Symbol} : {token, {list_to_atom(TokenChars), TokenLine}}.

%% The keywords that are identifiers, ,sigh.
message : {token, {t_message, TokenLine, message}}.
enum : {token, {t_enum, TokenLine, enum}}.
import : {token, {t_import, TokenLine, import}}.
public : {token, {t_public, TokenLine, public}}.
service : {token, {t_service, TokenLine, service}}.
package : {token, {t_package, TokenLine, package}}.
extend : {token, {t_extend, TokenLine, extend}}.
group : {token, {t_group, TokenLine, group}}.
extensions : {token, {t_extensions, TokenLine, extensions}}.
to : {token, {t_to, TokenLine, to}}.
max : {token, {t_max, TokenLine, max}}.
option : {token, {t_option, TokenLine, option}}.
rpc : {token, {t_rpc, TokenLine, rpc}}.
returns : {token, {t_returns, TokenLine, returns}}.
required : {token, {t_required, TokenLine, required}}.
optional : {token, {t_optional, TokenLine, optional}}.
repeated : {token, {t_repeated, TokenLine, repeated}}.

%% Booleans
true : {token, {t_bool, TokenLine, true}}.
false : {token, {t_bool, TokenLine, false}}.

{Float} : {token, {t_float, TokenLine, to_float(TokenChars)}}.
{DecInt} : {token, {t_integer, TokenLine, list_to_integer(TokenChars)}}.
{HexInt} : {token, {t_integer, TokenLine, hex_int(TokenChars)}}.
{OctInt} : {token, {t_integer, TokenLine, list_to_integer(TokenChars, 8)}}.

{Identifier}  : {token, {t_identifier, TokenLine, list_to_atom(TokenChars)}}.

{String} : {token, {t_string, TokenLine, TokenChars}}.

{Dot} : {token, {t_dot, TokenLine}}.

{Garbage} : {token, {t_garbage, TokenLine}}.


%% ===================================================================
%% Erlang code.
%% ===================================================================
Erlang code.

%% API
-export([file/1]).

%%====================================================================
%% API
%%====================================================================

%%--------------------------------------------------------------------
%% Function: file(FileName) -> Tokens.
%% @doc
%%   Tokenizes a .proto file.
%% @end
%%--------------------------------------------------------------------
-spec file(string()) -> [_].
%%--------------------------------------------------------------------
file(File) ->
    {ok, Bin} = file:read_file(File),
    {ok, Tokens, _} = string(binary_to_list(Bin)),
    Tokens.

%%====================================================================
%% Internal functions
%%====================================================================

hex_int("-0" ++ [_ | String]) -> list_to_integer([$- | String], 16);
hex_int([_, _ | String]) -> list_to_integer(String, 16).

to_float("nan") -> nan;
to_float("-inf") -> '-inf';
to_float("+inf") -> '+inf';
to_float("inf") -> '+inf';
to_float(String) ->
    case lists:member($., String) of
        true ->
            list_to_float(String);
        false ->
            [Int, Frac] = string:tokens(String, "eE"),
            list_to_float(lists:append([Int, ".0e", Frac]))
    end.
