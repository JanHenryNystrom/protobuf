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

-record(message,
        {name,
         body = []}).

-record(extension,
        {from :: integer(),
         to :: integer() | max}).

-record(rpc,
        {name,
         arg,
         return,
         options = []
        }).

-record(service,
        {name,
         option_rpc}).

-record(extend,
        {name,
         fields = [],
         group
        }).

-record(package, {name}).

-record(field,
        {label,
         type,
         name,
         tag,
         options}).

-record(group,
        {label,
         name,
         tag,
         parts = []}).

-record(import,
        {string,
         public = false :: boolean()
        }).

-record(option,
        {name,
         value = garbage
        }).

