package keeper

import (
	sdk "github.com/Fincor-Blockchain/cusp-sdk/types"

	"github.com/Fincor-Blockchain/cusp/cluster/evm/types"
)

// GetParams returns the total set of evm parameters.
func (k Keeper) GetParams(ctx sdk.Context) (params types.Params) {
	return k.CommitStateDB.WithContext(ctx).GetParams()
}

// SetParams sets the evm parameters to the param space.
func (k Keeper) SetParams(ctx sdk.Context, params types.Params) {
	k.CommitStateDB.WithContext(ctx).SetParams(params)
}
