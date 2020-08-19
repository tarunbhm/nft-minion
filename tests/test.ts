import { ethers } from "@nomiclabs/buidler";
import { expect } from "chai";
import { Signer } from "ethers";
import { Interface } from "ethers/lib/utils";
import { toWei } from "web3-utils";
import { Minion } from "../build/types/Minion";
import { MinionNft } from "../build/types/MinionNft";
import { Moloch } from "../build/types/Moloch";


const timeTravel = async (seconds: number) => {
  await ethers.provider.send('evm_increaseTime', [seconds])
  await ethers.provider.send('evm_mine', [])
}

describe("MinionNFT", function () {
  let accounts: Signer[], account1Address: string, account2Address: string, token, moloch: Moloch, minion: Minion, minionNft: MinionNft, minionNftInterface: Interface

  before('Deploy contracts', async function () {
    accounts = await ethers.getSigners()
    account1Address = await accounts[1].getAddress();
    account2Address = await accounts[2].getAddress();

    const testTokenFactory = await ethers.getContractFactory("TestToken")
    token = await testTokenFactory.deploy()

    await token.transfer(account1Address, toWei('100'))
    await token.transfer(account2Address, toWei('100'))

    const molochFactory = await ethers.getContractFactory("Moloch")
    moloch = await molochFactory.deploy(
      accounts[0].getAddress(),
      [token.address],
      60,
      10,
      10,
      10,
      3,
      1
    ) as unknown as Moloch

    await token.connect(accounts[1]).approve(moloch.address, toWei('100'))
    await token.connect(accounts[2]).approve(moloch.address, toWei('100'))

    await moloch.connect(accounts[1]).submitProposal(account1Address, 100, 0, toWei('100'), token.address, 0, token.address, '')
    await moloch.connect(accounts[2]).submitProposal(account2Address, 100, 0, toWei('100'), token.address, 0, token.address, '')

    await token.approve(moloch.address, toWei('800'))
    await moloch.sponsorProposal(0)
    await moloch.sponsorProposal(1)

    await timeTravel(120)
    await moloch.submitVote(0, 1)
    await moloch.submitVote(1, 1)

    await timeTravel(1200)
    await moloch.processProposal(0)
    await moloch.processProposal(1)

    const minionFactory = await ethers.getContractFactory("Minion")
    minion = await minionFactory.deploy(moloch.address) as unknown as Minion

    const minionNftFactory = await ethers.getContractFactory("MinionNFT")
    minionNftInterface = minionNftFactory.interface;
    minionNft = await minionNftFactory.deploy("Token 1", "MT1", minion.address) as unknown as MinionNft
  })

  it("should mint a token to a member", async function () {
    await minionNft.mint(account1Address)
    expect((await minionNft.balanceOf(account1Address))).to.equal(1)
  })

  it("should fail to mint a token to a non member", async function () {
    const address = await accounts[3].getAddress()
    await expect(minionNft.mint(address)).to.be.revertedWith("MinionOwnable: caller is not the minion or not called for moloch member")
    expect((await minionNft.balanceOf(address))).to.equal(0)
  })

  it('should mint a token via minion to non member', async function () {
    const address = await accounts[4].getAddress()
    const encodedHexData = minionNftInterface.encodeFunctionData("mint(address)", [address])
    await minion.proposeAction(minionNft.address, 0, encodedHexData, 'Mint NFT to non member address')
    await moloch.sponsorProposal(2)

    await timeTravel(120)
    await moloch.submitVote(2, 1)
    await moloch.connect(accounts[1]).submitVote(2, 1)
    await moloch.connect(accounts[2]).submitVote(2, 1)

    await timeTravel(1200)
    await moloch.processProposal(2)

    await minion.executeAction(2)
    expect(await minionNft.balanceOf(address)).to.equal(1)
  })
})
