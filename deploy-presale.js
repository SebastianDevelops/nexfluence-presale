const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying Presale contract to Polygon Mainnet...");
    
    // Get the deployer account
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    
    // Check deployer balance
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.formatEther(balance), "MATIC");
    
    if (balance < ethers.parseEther("0.5")) {
        throw new Error("Insufficient MATIC balance. Need at least 0.5 MATIC for deployment.");
    }
    
    // Configuration for Polygon Mainnet
    const NEX_TOKEN_ADDRESS = process.env.NEX_TOKEN_ADDRESS;
    const USDC_TOKEN_ADDRESS = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"; // USDC on Polygon Mainnet
    const HARD_CAP_IN_USDC = 15000000; // $15M hard cap
    const DURATION_IN_DAYS = 365; // 12 months (365 days)
    const MULTISIG_ADDRESS = process.env.MULTISIG_ADDRESS;
    
    if (!ethers.isAddress(NEX_TOKEN_ADDRESS)) {
        throw new Error("Invalid NEX token address");
    }
    
    if (!ethers.isAddress(MULTISIG_ADDRESS)) {
        throw new Error("Invalid multisig address");
    }
    
    console.log("NEX Token address:", NEX_TOKEN_ADDRESS);
    console.log("USDC Token address:", USDC_TOKEN_ADDRESS);
    console.log("Multisig address:", MULTISIG_ADDRESS);
    console.log("Hard cap:", HARD_CAP_IN_USDC, "USDC");
    console.log("Duration:", DURATION_IN_DAYS, "days");
    
    // Deploy Presale contract
    const PresaleFactory = await ethers.getContractFactory("Presale");
    
    console.log("Deploying Presale contract...");
    const presale = await PresaleFactory.deploy(
        NEX_TOKEN_ADDRESS,
        USDC_TOKEN_ADDRESS,
        HARD_CAP_IN_USDC,
        DURATION_IN_DAYS,
        MULTISIG_ADDRESS,
        {
            gasLimit: 3000000, // Set gas limit for Polygon
        }
    );
    
    console.log("Waiting for deployment transaction...");
    await presale.waitForDeployment();
    
    const contractAddress = await presale.getAddress();
    console.log("✅ Presale Contract deployed successfully!");
    console.log("Contract address:", contractAddress);
    console.log("Transaction hash:", presale.deploymentTransaction().hash);
    
    // Wait for confirmations
    console.log("Waiting for 3 confirmations...");
    await presale.deploymentTransaction().wait(3);
    
    // Verify contract details
    const nexTokenAddress = await presale.nexToken();
    const usdcTokenAddress = await presale.usdcToken();
    const hardCap = await presale.hardCapInUsdc();
    const startTime = await presale.startTime();
    const endTime = await presale.endTime();
    
    console.log("\n📊 Contract Details:");
    console.log("NEX Token:", nexTokenAddress);
    console.log("USDC Token:", usdcTokenAddress);
    console.log("Hard Cap:", ethers.formatUnits(hardCap, 6), "USDC");
    console.log("Start Time:", new Date(Number(startTime) * 1000).toLocaleString());
    console.log("End Time:", new Date(Number(endTime) * 1000).toLocaleString());
    
    // Log deployment info for records
    const deploymentInfo = {
        network: "Polygon Mainnet",
        contractAddress: contractAddress,
        deployerAddress: deployer.address,
        multisigAddress: MULTISIG_ADDRESS,
        nexTokenAddress: NEX_TOKEN_ADDRESS,
        usdcTokenAddress: USDC_TOKEN_ADDRESS,
        hardCap: ethers.formatUnits(hardCap, 6) + " USDC",
        duration: DURATION_IN_DAYS + " days",
        transactionHash: presale.deploymentTransaction().hash,
        blockNumber: presale.deploymentTransaction().blockNumber,
        timestamp: new Date().toISOString(),
        gasUsed: presale.deploymentTransaction().gasLimit?.toString() || "N/A",
    };
    
    console.log("\n📋 Deployment Summary:");
    console.table(deploymentInfo);
    
    console.log("\n🔗 Useful Links:");
    console.log(`PolygonScan: https://polygonscan.com/address/${contractAddress}`);
    console.log(`Transaction: https://polygonscan.com/tx/${presale.deploymentTransaction().hash}`);
    
    console.log("\n✨ Deployment completed successfully!");
    
    // Important next steps
    console.log("\n⚠️ IMPORTANT NEXT STEPS:");
    console.log("1. Transfer NEX tokens to the presale contract");
    console.log(`   - Send tokens from multisig to: ${contractAddress}`);
    console.log(`   - Required amount: ${(HARD_CAP_IN_USDC / 0.05).toLocaleString()} NEX tokens`);
    console.log("2. Verify the contract on PolygonScan");
    console.log(`   - Run: npx hardhat verify --network polygon ${contractAddress} ${NEX_TOKEN_ADDRESS} ${USDC_TOKEN_ADDRESS} ${HARD_CAP_IN_USDC} ${DURATION_IN_DAYS} ${MULTISIG_ADDRESS}`);
    console.log("3. Update the website with the new contract address");
    console.log("\n💡 NEX Token Transfer Command (run from multisig):");
    console.log(`await nexToken.transfer("${contractAddress}", ethers.parseEther("${(HARD_CAP_IN_USDC / 0.05).toLocaleString()}"));`);
    
    return {
        presale: contractAddress,
        deployer: deployer.address,
        multisig: MULTISIG_ADDRESS
    };
}

// Execute deployment
if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error("❌ Deployment failed:");
            console.error(error);
            process.exit(1);
        });
}

module.exports = main;