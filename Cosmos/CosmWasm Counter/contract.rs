// Контракт-счетчик для CosmWasm (Cosmos SDK) на Rust.
// Та же логика, что в Solana/Counter, но в модели CosmWasm:
// у контракта есть свое хранилище (deps.storage), а вызовы делятся
// на три типа - instantiate (создание), execute (изменение), query (чтение).
// В боевом проекте msg.rs, state.rs и contract.rs разносят по файлам -
// здесь все в одном, чтобы читать сверху вниз.

use cosmwasm_std::{
    entry_point, to_binary, Binary, Deps, DepsMut, Env, MessageInfo, Response, StdError,
    StdResult,
};
use cosmwasm_storage::{singleton, singleton_read};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

// Ключ, под которым состояние лежит в хранилище контракта
static STATE_KEY: &[u8] = b"state";

// Состояние контракта: значение счетчика и адрес владельца
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct State {
    pub value: u64,
    // В Cosmos адреса - это строки в формате bech32 (cosmos1...)
    pub owner: String,
}

// Сообщение создания: с какого числа начать счет
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InstantiateMsg {
    pub start_value: u64,
}

// Сообщения изменения состояния.
// enum с вариантами - стандартный способ описать команды контракта
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    // Увеличить счетчик - может кто угодно
    Increment {},
    // Сбросить в ноль - только владелец
    Reset {},
}

// Сообщения чтения
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum QueryMsg {
    GetValue {},
}

// instantiate вызывается один раз при создании контракта -
// аналог constructor в Solidity
#[entry_point]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> StdResult<Response> {
    let state = State {
        value: msg.start_value,
        // info.sender - тот, кто отправил транзакцию создания
        owner: info.sender.to_string(),
    };
    // singleton - хранилище ровно одного значения по ключу
    singleton(deps.storage, STATE_KEY).save(&state)?;
    Ok(Response::new().add_attribute("action", "instantiate"))
}

// execute обрабатывает все команды, меняющие состояние
#[entry_point]
pub fn execute(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> StdResult<Response> {
    match msg {
        ExecuteMsg::Increment {} => {
            let mut state: State = singleton_read(deps.storage, STATE_KEY).load()?;
            // Защита от переполнения, как и везде в блокчейне
            state.value = state
                .value
                .checked_add(1)
                .ok_or_else(|| StdError::generic_err("переполнение счетчика"))?;
            singleton(deps.storage, STATE_KEY).save(&state)?;
            Ok(Response::new().add_attribute("action", "increment"))
        }
        ExecuteMsg::Reset {} => {
            let mut state: State = singleton_read(deps.storage, STATE_KEY).load()?;
            // Проверка прав: сбросить может только владелец.
            // Аналог модификатора onlyOwner из Solidity
            if info.sender.to_string() != state.owner {
                return Err(StdError::generic_err("только владелец может сбросить"));
            }
            state.value = 0;
            singleton(deps.storage, STATE_KEY).save(&state)?;
            Ok(Response::new().add_attribute("action", "reset"))
        }
    }
}

// query читает состояние, ничего не меняя - газ не тратится
#[entry_point]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetValue {} => {
            let state: State = singleton_read(deps.storage, STATE_KEY).load()?;
            // Ответ сериализуется в JSON-байты
            to_binary(&state.value)
        }
    }
}
