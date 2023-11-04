// SPDX-License-Identifier: UNLICENSED
import {IAllowlist, Allowlist} from "../contracts/utils/Allowlist.sol";

import "forge-std/Script.sol";

contract AddToAllowList {
    function add(address listAddr_) external {
        IAllowlist(listAddr_).addOwner(0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3);
        IAllowlist(listAddr_).addOwner(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a);
        IAllowlist(listAddr_).addOwner(0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43);
        IAllowlist(listAddr_).addOwner(0xcD3942171C362448cBD4FAeA6b2B71c8cCe40BF3);
        IAllowlist(listAddr_).addOwner(0x91dD610E5cBe132A833F42c2dF0b2eafa965DA40);
        IAllowlist(listAddr_).addOwner(0x7660aa261d27A2A32d4e7e605C1bc2BA515E5f81);
        IAllowlist(listAddr_).addOwner(0x55954C2C092f6e973B55C5D2Af28950b3b6D1338);
        IAllowlist(listAddr_).addOwner(0x06a0cC2bF3F4B1b7f725ccaB1D7A51547c48B8Fc);
        IAllowlist(listAddr_).addOwner(0x61Be760b4fFb521657f585b392E3a446F4BB563d);

        address[] memory addToAllow = new address[](9);
        addToAllow[0] = 0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3;
        addToAllow[1] = 0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a;
        addToAllow[2] = 0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43;
        addToAllow[3] = 0xcD3942171C362448cBD4FAeA6b2B71c8cCe40BF3;
        addToAllow[4] = 0x91dD610E5cBe132A833F42c2dF0b2eafa965DA40;
        addToAllow[5] = 0x7660aa261d27A2A32d4e7e605C1bc2BA515E5f81;
        addToAllow[6] = 0x55954C2C092f6e973B55C5D2Af28950b3b6D1338;
        addToAllow[7] = 0x06a0cC2bF3F4B1b7f725ccaB1D7A51547c48B8Fc;
        addToAllow[8] = 0x61Be760b4fFb521657f585b392E3a446F4BB563d;
        IAllowlist(listAddr_).addBatchToAllowlist(addToAllow);
    }
}
