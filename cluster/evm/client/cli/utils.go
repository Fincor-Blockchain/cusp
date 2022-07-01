package cli

import (
	"fmt"
	"strings"

	"github.com/pkg/errors"

	"github.com/ethereum/go-ethereum/common"

	sdk "github.com/Fincor-Blockchain/cusp-sdk/types"
)

func accountToHex(addr string) (string, error) {
	if strings.HasPrefix(addr, sdk.GetConfig().GetBech32AccountAddrPrefix()) {
		toAddr, err := sdk.AccAddressFromBech32(addr)
		if err != nil {
			return "", errors.Wrap(err, "must provide a valid Bech32 address")
		}
		ethAddr := common.BytesToAddress(toAddr.Bytes())
		return ethAddr.Hex(), nil
	}

	if !strings.HasPrefix(addr, "0x") {
		addr = "0x" + addr
	}

	valid := common.IsHexAddress(addr)
	if !valid {
		return "", fmt.Errorf("%s is not a valid Ethereum address", addr)
	}

	ethAddr := common.HexToAddress(addr)

	return ethAddr.Hex(), nil
}

func formatKeyToHash(key string) string {
	if !strings.HasPrefix(key, "0x") {
		key = "0x" + key
	}

	ethkey := common.HexToHash(key)

	return ethkey.Hex()
}
