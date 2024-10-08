-module(openapi_api).
-moduledoc """
This module offers an API for JSON schema validation, using `jesse` under the hood.

If validation is desired, a jesse state can be loaded using `prepare_validator/1`,
and request and response can be validated using `populate_request/3`
and `validate_response/4` respectively.

For example, the user-defined `Module:accept_callback/4` can be implemented as follows:
```
-spec accept_callback(atom(), openapi_api:operation_id(), cowboy_req:req(), context()) ->
    {cowboy:http_status(), cowboy:http_headers(), json:encode_value()}.
accept_callback(Class, OperationID, Req, Context) ->
    ValidatorState = openapi_api:prepare_validator(),
    case openapi_api:populate_request(OperationID, Req0, ValidatorState) of
        {ok, Populated, Req1} ->
            {Code, Headers, Body} = openapi_logic_handler:handle_request(
                LogicHandler,
                OperationID,
                Req1,
                maps:merge(State#state.context, Populated)
            ),
            _ = openapi_api:validate_response(
                OperationID,
                Code,
                Body,
                ValidatorState
            ),
            PreparedBody = prepare_body(Code, Body),
            Response = {ok, {Code, Headers, PreparedBody}},
            process_response(Response, Req1, State);
        {error, Reason, Req1} ->
            process_response({error, Reason}, Req1, State)
    end.
```
""".

-export([prepare_validator/0, prepare_validator/1, prepare_validator/2]).
-export([populate_request/3, validate_response/4]).

-ignore_xref([populate_request/3, validate_response/4]).
-ignore_xref([prepare_validator/0, prepare_validator/1, prepare_validator/2]).

-type operation_id() :: atom().
-type request_param() :: atom().

-export_type([operation_id/0]).

-dialyzer({nowarn_function, [to_binary/1, validate_response_body/4]}).

-type rule() ::
    {type, binary} |
    {type, integer} |
    {type, float} |
    {type, boolean} |
    {type, date} |
    {type, datetime} |
    {enum, [atom()]} |
    {max, Max :: number()} |
    {exclusive_max, Max :: number()} |
    {min, Min :: number()} |
    {exclusive_min, Min :: number()} |
    {max_length, MaxLength :: integer()} |
    {min_length, MaxLength :: integer()} |
    {pattern, Pattern :: string()} |
    schema |
    required |
    not_required.

-doc #{equiv => prepare_validator/2}.
-spec prepare_validator() -> jesse_state:state().
prepare_validator() ->
    prepare_validator(<<"http://json-schema.org/draft-06/schema#">>).

-doc #{equiv => prepare_validator/2}.
-spec prepare_validator(binary()) -> jesse_state:state().
prepare_validator(SchemaVer) ->
    prepare_validator(get_openapi_path(), SchemaVer).

-doc """
Loads the JSON schema and the desired validation draft into a `t:jesse_state:state()`.
""".
-spec prepare_validator(file:name_all(), binary()) -> jesse_state:state().
prepare_validator(OpenApiPath, SchemaVer) ->
    {ok, FileContents} = file:read_file(OpenApiPath),
    R = json:decode(FileContents),
    jesse_state:new(R, [{default_schema_ver, SchemaVer}]).

-doc """
Automatically loads the entire body from the cowboy req
and validates the JSON body against the schema.
""".
-spec populate_request(
        OperationID :: operation_id(),
        Req :: cowboy_req:req(),
        ValidatorState :: jesse_state:state()) ->
    {ok, Model :: #{}, Req :: cowboy_req:req()} |
    {error, Reason :: any(), Req :: cowboy_req:req()}.
populate_request(OperationID, Req, ValidatorState) ->
    Params = request_params(OperationID),
    populate_request_params(OperationID, Params, Req, ValidatorState, #{}).

-doc """
Validates that the provided `Code` and `Body` comply with the `ValidatorState` schema
for the `OperationID` operation.
""".
-spec validate_response(
        OperationID :: operation_id(),
        Code :: 200..599,
        Body :: jesse:json_term(),
        ValidatorState :: jesse_state:state()) ->
    ok | {ok, term()} | [ok | {ok, term()}] | no_return().
validate_response('TestAuthHttpBasic', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestAuthHttpBearer', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestBinaryGif', 200, Body, ValidatorState) ->
    validate_response_body('file', 'file', Body, ValidatorState);
validate_response('TestBodyApplicationOctetstreamBinary', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestBodyMultipartFormdataArrayOfBinary', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestBodyMultipartFormdataSingleBinary', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestEchoBodyAllOfPet', 200, Body, ValidatorState) ->
    validate_response_body('Pet', 'Pet', Body, ValidatorState);
validate_response('TestEchoBodyFreeFormObjectResponseString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestEchoBodyPet', 200, Body, ValidatorState) ->
    validate_response_body('Pet', 'Pet', Body, ValidatorState);
validate_response('TestEchoBodyPetResponseString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestEchoBodyStringEnum', 200, Body, ValidatorState) ->
    validate_response_body('StringEnumRef', 'StringEnumRef', Body, ValidatorState);
validate_response('TestEchoBodyTagResponseString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestFormIntegerBooleanString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestFormObjectMultipart', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestFormOneof', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestHeaderIntegerBooleanStringEnums', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestsPathString{pathString}Integer{pathInteger}{enumNonrefStringPath}{enumRefStringPath}', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestEnumRefString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryDatetimeDateString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryIntegerBooleanString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryStyleDeepObjectExplodeTrueObject', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryStyleDeepObjectExplodeTrueObjectAllOf', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryStyleFormExplodeFalseArrayInteger', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryStyleFormExplodeFalseArrayString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryStyleFormExplodeTrueArrayString', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryStyleFormExplodeTrueObject', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response('TestQueryStyleFormExplodeTrueObjectAllOf', 200, Body, ValidatorState) ->
    validate_response_body('binary', 'string', Body, ValidatorState);
validate_response(_OperationID, _Code, _Body, _ValidatorState) ->
    ok.

%%%
-spec request_params(OperationID :: operation_id()) -> [Param :: request_param()].
request_params('TestAuthHttpBasic') ->
    [
    ];
request_params('TestAuthHttpBearer') ->
    [
    ];
request_params('TestBinaryGif') ->
    [
    ];
request_params('TestBodyApplicationOctetstreamBinary') ->
    [
        'file'
    ];
request_params('TestBodyMultipartFormdataArrayOfBinary') ->
    [
        'files'
    ];
request_params('TestBodyMultipartFormdataSingleBinary') ->
    [
        'my-file'
    ];
request_params('TestEchoBodyAllOfPet') ->
    [
        'Pet'
    ];
request_params('TestEchoBodyFreeFormObjectResponseString') ->
    [
        'object'
    ];
request_params('TestEchoBodyPet') ->
    [
        'Pet'
    ];
request_params('TestEchoBodyPetResponseString') ->
    [
        'Pet'
    ];
request_params('TestEchoBodyStringEnum') ->
    [
        'binary'
    ];
request_params('TestEchoBodyTagResponseString') ->
    [
        'Tag'
    ];
request_params('TestFormIntegerBooleanString') ->
    [
        'integer_form',
        'boolean_form',
        'string_form'
    ];
request_params('TestFormObjectMultipart') ->
    [
        'marker'
    ];
request_params('TestFormOneof') ->
    [
        'form1',
        'form2',
        'form3',
        'form4',
        'id',
        'name'
    ];
request_params('TestHeaderIntegerBooleanStringEnums') ->
    [
        'integer_header',
        'boolean_header',
        'string_header',
        'enum_nonref_string_header',
        'enum_ref_string_header'
    ];
request_params('TestsPathString{pathString}Integer{pathInteger}{enumNonrefStringPath}{enumRefStringPath}') ->
    [
        'path_string',
        'path_integer',
        'enum_nonref_string_path',
        'enum_ref_string_path'
    ];
request_params('TestEnumRefString') ->
    [
        'enum_nonref_string_query',
        'enum_ref_string_query'
    ];
request_params('TestQueryDatetimeDateString') ->
    [
        'datetime_query',
        'date_query',
        'string_query'
    ];
request_params('TestQueryIntegerBooleanString') ->
    [
        'integer_query',
        'boolean_query',
        'string_query'
    ];
request_params('TestQueryStyleDeepObjectExplodeTrueObject') ->
    [
        'query_object'
    ];
request_params('TestQueryStyleDeepObjectExplodeTrueObjectAllOf') ->
    [
        'query_object'
    ];
request_params('TestQueryStyleFormExplodeFalseArrayInteger') ->
    [
        'query_object'
    ];
request_params('TestQueryStyleFormExplodeFalseArrayString') ->
    [
        'query_object'
    ];
request_params('TestQueryStyleFormExplodeTrueArrayString') ->
    [
        'query_object'
    ];
request_params('TestQueryStyleFormExplodeTrueObject') ->
    [
        'query_object'
    ];
request_params('TestQueryStyleFormExplodeTrueObjectAllOf') ->
    [
        'query_object'
    ];
request_params(_) ->
    error(unknown_operation).

-spec request_param_info(OperationID :: operation_id(), Name :: request_param()) ->
    #{source => qs_val | binding | header | body, rules => [rule()]}.
request_param_info('TestBodyApplicationOctetstreamBinary', 'file') ->
    #{
        source => body,
        rules => [
            {type, binary},
            schema,
            not_required
        ]
    };
request_param_info('TestBodyMultipartFormdataArrayOfBinary', 'files') ->
    #{
        source => body,
        rules => [
            required
        ]
    };
request_param_info('TestBodyMultipartFormdataSingleBinary', 'my-file') ->
    #{
        source => body,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestEchoBodyAllOfPet', 'Pet') ->
    #{
        source => body,
        rules => [
            schema,
            not_required
        ]
    };
request_param_info('TestEchoBodyFreeFormObjectResponseString', 'object') ->
    #{
        source => body,
        rules => [
            schema,
            not_required
        ]
    };
request_param_info('TestEchoBodyPet', 'Pet') ->
    #{
        source => body,
        rules => [
            schema,
            not_required
        ]
    };
request_param_info('TestEchoBodyPetResponseString', 'Pet') ->
    #{
        source => body,
        rules => [
            schema,
            not_required
        ]
    };
request_param_info('TestEchoBodyStringEnum', 'binary') ->
    #{
        source => body,
        rules => [
            schema,
            not_required
        ]
    };
request_param_info('TestEchoBodyTagResponseString', 'Tag') ->
    #{
        source => body,
        rules => [
            schema,
            not_required
        ]
    };
request_param_info('TestFormIntegerBooleanString', 'integer_form') ->
    #{
        source => body,
        rules => [
            {type, integer},
            not_required
        ]
    };
request_param_info('TestFormIntegerBooleanString', 'boolean_form') ->
    #{
        source => body,
        rules => [
            {type, boolean},
            not_required
        ]
    };
request_param_info('TestFormIntegerBooleanString', 'string_form') ->
    #{
        source => body,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestFormObjectMultipart', 'marker') ->
    #{
        source => body,
        rules => [
            required
        ]
    };
request_param_info('TestFormOneof', 'form1') ->
    #{
        source => body,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestFormOneof', 'form2') ->
    #{
        source => body,
        rules => [
            {type, integer},
            not_required
        ]
    };
request_param_info('TestFormOneof', 'form3') ->
    #{
        source => body,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestFormOneof', 'form4') ->
    #{
        source => body,
        rules => [
            {type, boolean},
            not_required
        ]
    };
request_param_info('TestFormOneof', 'id') ->
    #{
        source => body,
        rules => [
            {type, integer},
            not_required
        ]
    };
request_param_info('TestFormOneof', 'name') ->
    #{
        source => body,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestHeaderIntegerBooleanStringEnums', 'integer_header') ->
    #{
        source => header,
        rules => [
            {type, integer},
            not_required
        ]
    };
request_param_info('TestHeaderIntegerBooleanStringEnums', 'boolean_header') ->
    #{
        source => header,
        rules => [
            {type, boolean},
            not_required
        ]
    };
request_param_info('TestHeaderIntegerBooleanStringEnums', 'string_header') ->
    #{
        source => header,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestHeaderIntegerBooleanStringEnums', 'enum_nonref_string_header') ->
    #{
        source => header,
        rules => [
            {type, binary},
            {enum, ['success', 'failure', 'unclassified'] },
            not_required
        ]
    };
request_param_info('TestHeaderIntegerBooleanStringEnums', 'enum_ref_string_header') ->
    #{
        source => header,
        rules => [
            not_required
        ]
    };
request_param_info('TestsPathString{pathString}Integer{pathInteger}{enumNonrefStringPath}{enumRefStringPath}', 'path_string') ->
    #{
        source => binding,
        rules => [
            {type, binary},
            required
        ]
    };
request_param_info('TestsPathString{pathString}Integer{pathInteger}{enumNonrefStringPath}{enumRefStringPath}', 'path_integer') ->
    #{
        source => binding,
        rules => [
            {type, integer},
            required
        ]
    };
request_param_info('TestsPathString{pathString}Integer{pathInteger}{enumNonrefStringPath}{enumRefStringPath}', 'enum_nonref_string_path') ->
    #{
        source => binding,
        rules => [
            {type, binary},
            {enum, ['success', 'failure', 'unclassified'] },
            required
        ]
    };
request_param_info('TestsPathString{pathString}Integer{pathInteger}{enumNonrefStringPath}{enumRefStringPath}', 'enum_ref_string_path') ->
    #{
        source => binding,
        rules => [
            required
        ]
    };
request_param_info('TestEnumRefString', 'enum_nonref_string_query') ->
    #{
        source => qs_val,
        rules => [
            {type, binary},
            {enum, ['success', 'failure', 'unclassified'] },
            not_required
        ]
    };
request_param_info('TestEnumRefString', 'enum_ref_string_query') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info('TestQueryDatetimeDateString', 'datetime_query') ->
    #{
        source => qs_val,
        rules => [
            {type, datetime},
            not_required
        ]
    };
request_param_info('TestQueryDatetimeDateString', 'date_query') ->
    #{
        source => qs_val,
        rules => [
            {type, date},
            not_required
        ]
    };
request_param_info('TestQueryDatetimeDateString', 'string_query') ->
    #{
        source => qs_val,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestQueryIntegerBooleanString', 'integer_query') ->
    #{
        source => qs_val,
        rules => [
            {type, integer},
            not_required
        ]
    };
request_param_info('TestQueryIntegerBooleanString', 'boolean_query') ->
    #{
        source => qs_val,
        rules => [
            {type, boolean},
            not_required
        ]
    };
request_param_info('TestQueryIntegerBooleanString', 'string_query') ->
    #{
        source => qs_val,
        rules => [
            {type, binary},
            not_required
        ]
    };
request_param_info('TestQueryStyleDeepObjectExplodeTrueObject', 'query_object') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info('TestQueryStyleDeepObjectExplodeTrueObjectAllOf', 'query_object') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info('TestQueryStyleFormExplodeFalseArrayInteger', 'query_object') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info('TestQueryStyleFormExplodeFalseArrayString', 'query_object') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info('TestQueryStyleFormExplodeTrueArrayString', 'query_object') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info('TestQueryStyleFormExplodeTrueObject', 'query_object') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info('TestQueryStyleFormExplodeTrueObjectAllOf', 'query_object') ->
    #{
        source => qs_val,
        rules => [
            not_required
        ]
    };
request_param_info(OperationID, Name) ->
    error({unknown_param, OperationID, Name}).

-spec populate_request_params(
        operation_id(), [request_param()], cowboy_req:req(), jesse_state:state(), map()) ->
    {ok, map(), cowboy_req:req()} | {error, _, cowboy_req:req()}.
populate_request_params(_, [], Req, _, Model) ->
    {ok, Model, Req};
populate_request_params(OperationID, [ReqParamName | T], Req0, ValidatorState, Model0) ->
    case populate_request_param(OperationID, ReqParamName, Req0, ValidatorState) of
        {ok, V, Req} ->
            Model = maps:put(ReqParamName, V, Model0),
            populate_request_params(OperationID, T, Req, ValidatorState, Model);
        Error ->
            Error
    end.

-spec populate_request_param(
        operation_id(), request_param(), cowboy_req:req(), jesse_state:state()) ->
    {ok, term(), cowboy_req:req()} | {error, term(), cowboy_req:req()}.
populate_request_param(OperationID, ReqParamName, Req0, ValidatorState) ->
    #{rules := Rules, source := Source} = request_param_info(OperationID, ReqParamName),
    case get_value(Source, ReqParamName, Req0) of
        {error, Reason, Req} ->
            {error, Reason, Req};
        {Value, Req} ->
            case prepare_param(Rules, ReqParamName, Value, ValidatorState) of
                {ok, Result} -> {ok, Result, Req};
                {error, Reason} ->
                    {error, Reason, Req}
            end
    end.

-include_lib("kernel/include/logger.hrl").

validate_response_body(list, ReturnBaseType, Body, ValidatorState) ->
    [
        validate(schema, Item, ReturnBaseType, ValidatorState)
    || Item <- Body];

validate_response_body(_, ReturnBaseType, Body, ValidatorState) ->
    validate(schema, Body, ReturnBaseType, ValidatorState).

-spec validate(rule(), term(), request_param(), jesse_state:state()) ->
    ok | {ok, term()}.
validate(required, undefined, ReqParamName, _) ->
    validation_error(required, ReqParamName, undefined);
validate(required, _Value, _ReqParamName, _) ->
    ok;
validate(not_required, _Value, _ReqParamName, _) ->
    ok;
validate(_, undefined, _ReqParamName, _) ->
    ok;
validate({type, boolean}, Value, _ReqParamName, _) when is_boolean(Value) ->
    {ok, Value};
validate({type, integer}, Value, _ReqParamName, _) when is_integer(Value) ->
    ok;
validate({type, float}, Value, _ReqParamName, _) when is_float(Value) ->
    ok;
validate({type, binary}, Value, _ReqParamName, _) when is_binary(Value) ->
    ok;
validate(Rule = {type, binary}, Value, ReqParamName, _) ->
    validation_error(Rule, ReqParamName, Value);
validate(Rule = {type, boolean}, Value, ReqParamName, _) ->
    case binary_to_lower(Value) of
        <<"true">> -> {ok, true};
        <<"false">> -> {ok, false};
        _ -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {type, integer}, Value, ReqParamName, _) ->
    try
        {ok, to_int(Value)}
    catch
        error:badarg ->
            validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {type, float}, Value, ReqParamName, _) ->
    try
        {ok, to_float(Value)}
    catch
        error:badarg ->
            validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {type, date}, Value, ReqParamName, _) ->
    case is_binary(Value) of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {type, datetime}, Value, ReqParamName, _) ->
    case is_binary(Value) of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {enum, Values}, Value, ReqParamName, _) ->
    try
        FormattedValue = erlang:binary_to_existing_atom(Value, utf8),
        case lists:member(FormattedValue, Values) of
            true -> {ok, FormattedValue};
            false -> validation_error(Rule, ReqParamName, Value)
        end
    catch
        error:badarg ->
            validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {max, Max}, Value, ReqParamName, _) ->
    case Value =< Max of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {exclusive_max, ExclusiveMax}, Value, ReqParamName, _) ->
    case Value > ExclusiveMax of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {min, Min}, Value, ReqParamName, _) ->
    case Value >= Min of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {exclusive_min, ExclusiveMin}, Value, ReqParamName, _) ->
    case Value =< ExclusiveMin of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {max_length, MaxLength}, Value, ReqParamName, _) ->
    case size(Value) =< MaxLength of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {min_length, MinLength}, Value, ReqParamName, _) ->
    case size(Value) >= MinLength of
        true -> ok;
        false -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = {pattern, Pattern}, Value, ReqParamName, _) ->
    {ok, MP} = re:compile(Pattern),
    case re:run(Value, MP) of
        {match, _} -> ok;
        _ -> validation_error(Rule, ReqParamName, Value)
    end;
validate(Rule = schema, Value, ReqParamName, ValidatorState) ->
    Definition = iolist_to_binary(["#/components/schemas/", atom_to_binary(ReqParamName)]),
    try
        _ = validate_with_schema(Value, Definition, ValidatorState),
        ok
    catch
        throw:[{schema_invalid, _, Error} | _] ->
            Info = #{
                type => schema_invalid,
                error => Error
            },
            validation_error(Rule, ReqParamName, Value, Info);
        throw:[{data_invalid, Schema, Error, _, Path} | _] ->
            Info = #{
                type => data_invalid,
                error => Error,
                schema => Schema,
                path => Path
            },
            validation_error(Rule, ReqParamName, Value, Info)
    end;
validate(Rule, _Value, ReqParamName, _) ->
    ?LOG_INFO(#{what => "Cannot validate rule", name => ReqParamName, rule => Rule}),
    error({unknown_validation_rule, Rule}).

-spec validation_error(rule(), request_param(), term()) -> no_return().
validation_error(ViolatedRule, Name, Value) ->
    validation_error(ViolatedRule, Name, Value, #{}).

-spec validation_error(rule(), request_param(), term(), Info :: #{_ := _}) -> no_return().
validation_error(ViolatedRule, Name, Value, Info) ->
    throw({wrong_param, Name, Value, ViolatedRule, Info}).

-spec get_value(body | qs_val | header | binding, request_param(), cowboy_req:req()) ->
    {any(), cowboy_req:req()} |
    {error, any(), cowboy_req:req()}.
get_value(body, _Name, Req0) ->
    {ok, Body, Req} = read_entire_body(Req0),
    case prepare_body(Body) of
        {error, Reason} ->
            {error, Reason, Req};
        Value ->
            {Value, Req}
    end;
get_value(qs_val, Name, Req) ->
    QS = cowboy_req:parse_qs(Req),
    Value = get_opt(to_qs(Name), QS),
    {Value, Req};
get_value(header, Name, Req) ->
    Headers = cowboy_req:headers(Req),
    Value =  maps:get(to_header(Name), Headers, undefined),
    {Value, Req};
get_value(binding, Name, Req) ->
    Value = cowboy_req:binding(Name, Req),
    {Value, Req}.

-spec read_entire_body(cowboy_req:req()) -> {ok, binary(), cowboy_req:req()}.
read_entire_body(Req) ->
    read_entire_body(Req, []).

-spec read_entire_body(cowboy_req:req(), iodata()) -> {ok, binary(), cowboy_req:req()}.
read_entire_body(Request, Acc) -> % {
    case cowboy_req:read_body(Request) of
        {ok, Data, NewRequest} ->
            {ok, iolist_to_binary(lists:reverse([Data | Acc])), NewRequest};
        {more, Data, NewRequest} ->
            read_entire_body(NewRequest, [Data | Acc])
    end.

prepare_body(<<>>) ->
    <<>>;
prepare_body(Body) ->
    try
        json:decode(Body)
    catch
        error:Error ->
            {error, {invalid_json, Body, Error}}
    end.

validate_with_schema(Body, Definition, ValidatorState) ->
    jesse_schema_validator:validate_with_state(
        [{<<"$ref">>, Definition}],
        Body,
        ValidatorState
    ).

-spec prepare_param([rule()], request_param(), term(), jesse_state:state()) ->
    {ok, term()} | {error, Reason :: any()}.
prepare_param(Rules, ReqParamName, Value, ValidatorState) ->
    Fun = fun(Rule, Acc) ->
        case validate(Rule, Acc, ReqParamName, ValidatorState) of
            ok -> Acc;
            {ok, Prepared} -> Prepared
        end
    end,
    try
        Result = lists:foldl(Fun, Value, Rules),
        {ok, Result}
    catch
        throw:Reason ->
            {error, Reason}
    end.

-spec to_binary(iodata() | atom() | number()) -> binary().
to_binary(V) when is_binary(V)  -> V;
to_binary(V) when is_list(V)    -> iolist_to_binary(V);
to_binary(V) when is_atom(V)    -> atom_to_binary(V, utf8);
to_binary(V) when is_integer(V) -> integer_to_binary(V);
to_binary(V) when is_float(V)   -> float_to_binary(V).

-spec to_float(binary() | list()) -> integer().
to_float(Data) when is_binary(Data) ->
    binary_to_float(Data);
to_float(Data) when is_list(Data) ->
    list_to_float(Data).

-spec to_int(binary() | list()) -> integer().
to_int(Data) when is_binary(Data) ->
    binary_to_integer(Data);
to_int(Data) when is_list(Data) ->
    list_to_integer(Data).

-spec to_header(request_param()) -> binary().
to_header(Name) ->
    to_binary(string:lowercase(atom_to_binary(Name, utf8))).

binary_to_lower(V) when is_binary(V) ->
    string:lowercase(V).

-spec to_qs(request_param()) -> binary().
to_qs(Name) ->
    atom_to_binary(Name, utf8).

-spec get_opt(any(), []) -> any().
get_opt(Key, Opts) ->
    get_opt(Key, Opts, undefined).

-spec get_opt(any(), [], any()) -> any().
get_opt(Key, Opts, Default) ->
    case lists:keyfind(Key, 1, Opts) of
        {_, Value} -> Value;
        false -> Default
    end.

get_openapi_path() ->
    {ok, AppName} = application:get_application(?MODULE),
    filename:join(priv_dir(AppName), "openapi.json").

-include_lib("kernel/include/file.hrl").

-spec priv_dir(Application :: atom()) -> file:name_all().
priv_dir(AppName) ->
    case code:priv_dir(AppName) of
        Value when is_list(Value) ->
            Value ++ "/";
        _Error ->
            select_priv_dir([filename:join(["apps", atom_to_list(AppName), "priv"]), "priv"])
     end.

select_priv_dir(Paths) ->
    case lists:dropwhile(fun test_priv_dir/1, Paths) of
        [Path | _] -> Path;
        _          -> exit(no_priv_dir)
    end.

test_priv_dir(Path) ->
    case file:read_file_info(Path) of
        {ok, #file_info{type = directory}} ->
            false;
        _ ->
            true
    end.
