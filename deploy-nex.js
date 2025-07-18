// filepath: c:\Users\vanro\Desktop\Projects\nexfluence-presale\deploy-nex-mainnet.js
const { ethers } = require("hardhat");

async function main() {
    console.log("🚀 Deploying NEX token to Polygon Mainnet...");
    
    // Get the deployer account
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    
    // Check deployer balance
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.formatEther(balance), "MATIC");
    
    if (balance < ethers.parseEther("0.5")) {
        throw new Error("⚠️ Insufficient balance for mainnet deployment. Need at least 0.5 MATIC.");
    }
    
    // Gnosis Safe multisig address
    const MULTISIG_ADDRESS = "0x2377dA0C9a890beb0b03187641d2f915C305a62a";
    
    if (!ethers.isAddress(MULTISIG_ADDRESS)) {
        throw new Error("Invalid multisig address");
    }
    
    console.log("🏦 Multisig address:", MULTISIG_ADDRESS);
    
    // Deploy NEX contract
    const NEXFactory = await ethers.getContractFactory("NEX");
    
    console.log("📦 Deploying NEX contract to Polygon Mainnet...");
    const nexToken = await NEXFactory.deploy(MULTISIG_ADDRESS, {
        gasLimit: 3000000,
        gasPrice: ethers.parseUnits("50", "gwei"), // Slightly higher for mainnet
    });
    
    console.log("⏳ Waiting for deployment transaction...");
    await nexToken.waitForDeployment();
    
    const contractAddress = await nexToken.getAddress();
    console.log("\n🎉 NEX Token deployed successfully to Polygon Mainnet!");
    console.log("📍 Contract address:", contractAddress);
    console.log("🔗 Transaction hash:", nexToken.deploymentTransaction().hash);
    console.log("🌐 View on PolygonScan:", `https://polygonscan.com/address/${contractAddress}`);
    
    // Wait for confirmations
    console.log("⏳ Waiting for 5 confirmations...");
    await nexToken.deploymentTransaction().wait(5);
    
    // Verify contract details
    const name = await nexToken.name();
    const symbol = await nexToken.symbol();
    const decimals = await nexToken.decimals();
    const totalSupply = await nexToken.totalSupply();
    const owner = await nexToken.getRoleMember(await nexToken.DEFAULT_ADMIN_ROLE(), 0);
    
    console.log("\n📋 NEX Token Details:");
    console.log("Name:", name);
    console.log("Symbol:", symbol);
    console.log("Decimals:", decimals.toString());
    console.log("Total Supply:", ethers.formatEther(totalSupply), "NEX");
    console.log("Owner (Multisig):", owner);
    
    console.log("\n🔗 Verification Command:");
    console.log(`npx hardhat verify --network polygon ${contractAddress} "${MULTISIG_ADDRESS}"`);
    
    console.log("\n✅ SUCCESS! NEX tokens are now in your Gnosis Safe wallet!");
    console.log("📝 Next steps:");
    console.log("1. Update .env file:");
    console.log(`   NEX_TOKEN_ADDRESS=${contractAddress}`);
    console.log("2. Update deploy-presale.js with the NEX token address");
    console.log("3. Deploy the presale contract");
    console.log("4. Transfer 300M NEX tokens from Gnosis Safe to presale contract");
    
    return contractAddress;
}

// Execute deployment
if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error("❌ Deployment failed:", error);
            process.exit(1);
        });
}

module.exports = main;