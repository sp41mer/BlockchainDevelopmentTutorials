// Программа-счетчик для Solana на Rust.
// Аналог простейшего контракта из папки Ethereum, но в модели Solana:
// программа не хранит состояние в себе - состояние живет в отдельных
// аккаунтах, которые передаются в каждый вызов.

// Подключаем базовые типы Solana
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};

// Подключаем Borsh - формат сериализации, которым Solana-программы
// обычно упаковывают состояние в байты аккаунта
use borsh::{BorshDeserialize, BorshSerialize};

// Объявляем структуру состояния - то, что лежит в data-аккаунте.
// derive автоматически генерирует код превращения структуры в байты и обратно
#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct Counter {
    // Значение счетчика. u64 - беззнаковое 64-битное число
    pub value: u64,
}

// Регистрируем точку входа: Solana вызовет process_instruction
// на каждую транзакцию, адресованную нашей программе
entrypoint!(process_instruction);

// Главная функция программы.
// program_id - адрес самой программы
// accounts - список аккаунтов, которые транзакция разрешила читать/менять
// instruction_data - байты с командой (у нас: 0 = увеличить, 1 = обнулить)
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    // Берем первый аккаунт из списка - в нем храним счетчик
    let accounts_iter = &mut accounts.iter();
    let counter_account = next_account_info(accounts_iter)?;

    // Проверяем, что аккаунтом владеет наша программа.
    // В Solana менять данные аккаунта может только программа-владелец.
    // Без этой проверки кто угодно подсунул бы чужой аккаунт
    if counter_account.owner != program_id {
        msg!("Аккаунт счетчика не принадлежит программе");
        return Err(ProgramError::IncorrectProgramId);
    }

    // Десериализуем текущее состояние из байтов аккаунта
    let mut counter = Counter::try_from_slice(&counter_account.data.borrow())?;

    // Читаем команду из первого байта instruction_data
    match instruction_data.first() {
        // Команда 0: увеличиваем счетчик на единицу.
        // checked_add защищает от переполнения - в блокчейне
        // молчаливое переполнение это уязвимость
        Some(0) => {
            counter.value = counter
                .value
                .checked_add(1)
                .ok_or(ProgramError::ArithmeticOverflow)?;
        }
        // Команда 1: обнуляем счетчик
        Some(1) => {
            counter.value = 0;
        }
        // Любой другой байт - неизвестная команда
        _ => return Err(ProgramError::InvalidInstructionData),
    }

    // Сериализуем обновленное состояние обратно в байты аккаунта
    counter.serialize(&mut &mut counter_account.data.borrow_mut()[..])?;

    // msg! - аналог console.log, видно в логах валидатора
    msg!("Счетчик теперь равен {}", counter.value);

    Ok(())
}
