// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import * as fs from 'fs';
import * as path from 'path';
import {ethers} from 'ethers'
import {writeFileSync} from "fs";


const hre = require('hardhat')


async function main() {
    //==================== todo The constructor is the value that needs to be passed in when the contract is deployed ====================
    let FactoryABI = ["function mixSwap(address ,address ,uint256 ,uint256 ,address[] ,address[] ,address[] ,uint256 ,bytes[] ,uint256 )"];
    let ifaceFactory = new ethers.utils.Interface(FactoryABI);
    let getABI = ifaceFactory.encodeFunctionData("mixSwap",
        [
            "0x55d398326f99059fF775485246999027B3197955",
            "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
            "337038228352079733",
            "1",
            ["0x8E4842d0570c85Ba3805A9508Dce7C6A458359d0", "0x165BA87e882208100672b6C56f477eE42502c820", "0x165BA87e882208100672b6C56f477eE42502c820"],
            ["0xBe60d4c4250438344bEC816Ec2deC99925dEb4c7", "0xA2F5e8261CAe83aaF960Cb2434AAEe342393Cc04", "0x393EBB91785b19881C07cB126fe1C25329eCc09b"],
            ["0x8E4842d0570c85Ba3805A9508Dce7C6A458359d0", "0xA2F5e8261CAe83aaF960Cb2434AAEe342393Cc04", "0x393EBB91785b19881C07cB126fe1C25329eCc09b", "0x6B3D817814eABc984d51896b1015C0b89E9737Ca"],
            1,
            ["0x00", "0x00", "0x00"],
            "1645785600"]);
    console.info(`getABI:` + getABI);

    /*    //==================== todo Deploy TestERC20 contract ====================
        const TestERC20 = await hre.ethers.getContractFactory("TestERC20");
        //Number,name,symbol of constructors passed in
        const testERC20 = await TestERC20.deploy("TEST", "TS", "100000000000000000000000000000000000000000000000000000000");
        await testERC20.deployed();
        console.log("TestERC20 deployed to:", testERC20.address);

        //==================== todo Deploy MerkleDistributorFactory Contract ====================
        const MerkleDistributorFactory = await hre.ethers.getContractFactory("MerkleDistributorFactory");
        //No constructor
        const merkleDistributorFactory = await MerkleDistributorFactory.deploy();
        await merkleDistributorFactory.deployed();
        console.log("MerkleDistributorFactory deployed to:", merkleDistributorFactory.address);

        //==================== todo Deploy ContractProxy Contract ====================
        const ContractProxy = await hre.ethers.getContractFactory("ContractProxy");
        //No constructor
        const contractProxy = await ContractProxy.deploy();
        await contractProxy.deployed();
        console.log("contractProxy deployed to:", contractProxy.address);

        //==================== todo Deploy TransparentUpgradeableProxy Contract ====================
        const TransparentUpgradeableProxy = await hre.ethers.getContractFactory("TransparentUpgradeableProxy");
        //No constructor
        const transparentUpgradeableProxy = await TransparentUpgradeableProxy.deploy(merkleDistributorFactory.address, contractProxy.address, getABI);
        await transparentUpgradeableProxy.deployed();
        console.log("transparentUpgradeableProxy deployed to:", transparentUpgradeableProxy.address);


        let Global1 = "{\n" +
            "  \"TestERC20\": \""+ testERC20.address +"\",\n" +
            "  \"proxyAdmin\": \""+ contractProxy.address +"\",\n" +
            "  \"MerkleDistributorFactory\": \""+ transparentUpgradeableProxy.address +"\"\n" +
            "}";
        addjson(Global1, "./other/contractAddr.json");*/
}

//生成持久化json文件
function addjson(data, address) {
    writeFileSync(address, data);
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
0x7617b38900000000000000000000000055d398326f99059ff775485246999027b3197955000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000004ad667ba4a717750000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000002e0000000000000000000000000000000000000000000000000000000006218b20000000000000000000000000000000000000000000000000000000000000000030000000000000000000000008e4842d0570c85ba3805a9508dce7c6a458359d0000000000000000000000000165ba87e882208100672b6c56f477ee42502c820000000000000000000000000165ba87e882208100672b6c56f477ee42502c8200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000be60d4c4250438344bec816ec2dec99925deb4c7000000000000000000000000a2f5e8261cae83aaf960cb2434aaee342393cc04000000000000000000000000393ebb91785b19881c07cb126fe1c25329ecc09b00000000000000000000000000000000000000000000000000000000000000040000000000000000000000008e4842d0570c85ba3805a9508dce7c6a458359d0000000000000000000000000a2f5e8261cae83aaf960cb2434aaee342393cc04000000000000000000000000393ebb91785b19881c07cb126fe1c25329ecc09b0000000000000000000000006b3d817814eabc984d51896b1015c0b89e9737ca0000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000
0x7617b38900000000000000000000000055d398326f99059ff775485246999027b3197955000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000004ad667ba4a717750000000000000000000000000000000000000000000000000003a9338bba464b000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000002e0000000000000000000000000000000000000000000000000000000006218b20000000000000000000000000000000000000000000000000000000000000000030000000000000000000000008e4842d0570c85ba3805a9508dce7c6a458359d0000000000000000000000000165ba87e882208100672b6c56f477ee42502c820000000000000000000000000165ba87e882208100672b6c56f477ee42502c8200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000be60d4c4250438344bec816ec2dec99925deb4c7000000000000000000000000a2f5e8261cae83aaf960cb2434aaee342393cc04000000000000000000000000393ebb91785b19881c07cb126fe1c25329ecc09b00000000000000000000000000000000000000000000000000000000000000040000000000000000000000008e4842d0570c85ba3805a9508dce7c6a458359d0000000000000000000000000a2f5e8261cae83aaf960cb2434aaee342393cc04000000000000000000000000393ebb91785b19881c07cb126fe1c25329ecc09b0000000000000000000000006b3d817814eabc984d51896b1015c0b89e9737ca0000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000
0x7617b38900000000000000000000000055d398326f99059ff775485246999027b3197955000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000004ad667ba4a717750000000000000000000000000000000000000000000000000003a9338bba464b000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000002e0000000000000000000000000000000000000000000000000000000006218b20000000000000000000000000000000000000000000000000000000000000000030000000000000000000000008e4842d0570c85ba3805a9508dce7c6a458359d0000000000000000000000000165ba87e882208100672b6c56f477ee42502c820000000000000000000000000165ba87e882208100672b6c56f477ee42502c8200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000be60d4c4250438344bec816ec2dec99925deb4c7000000000000000000000000a2f5e8261cae83aaf960cb2434aaee342393cc04000000000000000000000000393ebb91785b19881c07cb126fe1c25329ecc09b00000000000000000000000000000000000000000000000000000000000000040000000000000000000000008e4842d0570c85ba3805a9508dce7c6a458359d0000000000000000000000000a2f5e8261cae83aaf960cb2434aaee342393cc04000000000000000000000000393ebb91785b19881c07cb126fe1c25329ecc09b0000000000000000000000006b3d817814eabc984d51896b1015c0b89e9737ca0000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000