# Nexfluence Presale

This repository contains the smart contracts and frontend for the Nexfluence (NEX) token presale.

## Production Deployment Guide

### Prerequisites

- Node.js v16+ and npm
- Hardhat
- MetaMask or another Web3 wallet with Polygon Mainnet access
- MATIC for gas fees
- Multisig wallet for contract ownership

### Environment Setup

1. Create a `.env` file with the following variables:

```
PRIVATE_KEY=your_private_key_here
POLYGONSCAN_API_KEY=your_polygonscan_api_key_here
MULTISIG_ADDRESS=your_multisig_wallet_address
NEX_TOKEN_ADDRESS=deployed_nex_token_address
```

### Deployment Steps

#### 1. Deploy NEX Token

```bash
npx hardhat run deploy-nex.js --network polygon
```

After deployment, update the `NEX_TOKEN_ADDRESS` in your `.env` file with the deployed contract address.

#### 2. Deploy Presale Contract

```bash
npx hardhat run deploy-presale.js --network polygon
```

#### 3. Verify Contracts on PolygonScan

```bash
# Verify NEX Token
npx hardhat verify --network polygon <NEX_TOKEN_ADDRESS> <MULTISIG_ADDRESS>

# Verify Presale Contract
npx hardhat verify --network polygon <PRESALE_CONTRACT_ADDRESS> <NEX_TOKEN_ADDRESS> <USDC_TOKEN_ADDRESS> <HARD_CAP_IN_USDC> <DURATION_IN_DAYS> <MULTISIG_ADDRESS>
```

#### 4. Update Frontend Configuration

Update the following values in `index.html`:

```javascript
const CONFIG = {
    // ...
    presaleContractAddress: "0x...", // Your deployed presale contract address
    nexTokenAddress: "0x...", // Your deployed NEX token address
    // ...
};
```

#### 5. Transfer NEX Tokens to Presale Contract

Using your multisig wallet, transfer the required amount of NEX tokens to the presale contract address.

#### 6. Deploy Frontend

Deploy the frontend files to your web hosting service:
- index.html
- assets/ directory
- robots.txt
- sitemap.xml

### Contract Addresses (Polygon Mainnet)

- NEX Token: `0x...` (Update after deployment)
- Presale Contract: `0x...` (Update after deployment)
- USDC Token: `0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174`
- USDT Token: `0xc2132D05D31c914a87C6611C10748AEb04B58e8F`

### Presale Configuration

- Duration: 12 months (365 days)
- Token Price: $0.075 per NEX
- Hard Cap: $15,000,000
- Minimum Purchase: $100

## Security Considerations

- All contracts use OpenZeppelin's secure implementations
- Presale contract includes ReentrancyGuard protection
- Ownership is transferred to a multisig wallet for enhanced security
- Funds can only be withdrawn by the multisig owner

## Post-Deployment Verification

After deployment, verify:

1. The presale contract has received the correct amount of NEX tokens
2. The countdown timer is set correctly for 12 months
3. Wallet connection works properly on Polygon Mainnet
4. Test purchases work as expected (with small amounts)
5. The multisig wallet can successfully withdraw funds

## Support

For any issues or questions, please contact the Nexfluence team.