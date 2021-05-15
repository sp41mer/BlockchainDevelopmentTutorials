// Чейнкод (смарт-контракт) для Hyperledger Fabric на Go.
// Fabric - приватный блокчейн для консорциумов: ни газа, ни токенов,
// состояние - это key-value база (world state), разделяемая участниками.
// Логика та же, что в примерах Ethereum/Solana/Cosmos: создать актив,
// прочитать, передать другому владельцу.
package main

import (
	"encoding/json"
	"fmt"

	// Официальный SDK Fabric для написания контрактов на Go
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// Контракт - структура с методами. Каждый публичный метод
// становится вызываемой транзакцией
type SimpleAssetContract struct {
	contractapi.Contract
}

// Актив, который храним в леджере.
// Теги json задают формат, в котором актив лежит в world state
type Asset struct {
	ID    string `json:"id"`
	Owner string `json:"owner"`
	Value int    `json:"value"`
}

// CreateAsset создает новый актив.
// ctx дает доступ к леджеру (GetStub) и к личности вызывающего
func (c *SimpleAssetContract) CreateAsset(
	ctx contractapi.TransactionContextInterface,
	id string,
	owner string,
	value int,
) error {
	// Проверяем, что актива с таким id еще нет -
	// иначе можно было бы молча перезаписать чужой
	existing, err := ctx.GetStub().GetState(id)
	if err != nil {
		return fmt.Errorf("ошибка чтения леджера: %v", err)
	}
	if existing != nil {
		return fmt.Errorf("актив %s уже существует", id)
	}

	// Собираем актив и сериализуем в JSON
	asset := Asset{ID: id, Owner: owner, Value: value}
	assetBytes, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	// PutState записывает пару ключ-значение в world state.
	// Запись попадет в леджер только когда транзакцию
	// подтвердят пиры по политике эндорсмента
	return ctx.GetStub().PutState(id, assetBytes)
}

// ReadAsset читает актив по id
func (c *SimpleAssetContract) ReadAsset(
	ctx contractapi.TransactionContextInterface,
	id string,
) (*Asset, error) {
	assetBytes, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("ошибка чтения леджера: %v", err)
	}
	// nil означает, что по ключу ничего не записано
	if assetBytes == nil {
		return nil, fmt.Errorf("актив %s не найден", id)
	}

	// Десериализуем JSON обратно в структуру
	var asset Asset
	if err := json.Unmarshal(assetBytes, &asset); err != nil {
		return nil, err
	}
	return &asset, nil
}

// TransferAsset передает актив новому владельцу
func (c *SimpleAssetContract) TransferAsset(
	ctx contractapi.TransactionContextInterface,
	id string,
	newOwner string,
) error {
	// Переиспользуем ReadAsset - внутри уже есть все проверки
	asset, err := c.ReadAsset(ctx, id)
	if err != nil {
		return err
	}

	// Меняем владельца и записываем обратно.
	// Fabric хранит и историю изменений ключа - ее можно
	// получить через GetHistoryForKey
	asset.Owner = newOwner
	assetBytes, err := json.Marshal(asset)
	if err != nil {
		return err
	}
	return ctx.GetStub().PutState(id, assetBytes)
}

// Точка входа: регистрируем контракт и запускаем чейнкод.
// Fabric поднимет его в отдельном контейнере рядом с пиром
func main() {
	chaincode, err := contractapi.NewChaincode(&SimpleAssetContract{})
	if err != nil {
		panic(fmt.Sprintf("не удалось создать чейнкод: %v", err))
	}
	if err := chaincode.Start(); err != nil {
		panic(fmt.Sprintf("не удалось запустить чейнкод: %v", err))
	}
}
