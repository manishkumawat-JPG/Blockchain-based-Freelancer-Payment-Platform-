module  MyModule::FreelancerPayment {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a freelance contract.
    struct Contract has store, key {
        freelancer: address,  // Address of the freelancer
        client: address,      // Address of the client
        amount_due: u64,      // Amount to be paid to the freelancer
        paid_amount: u64,     // Amount that has been paid so far
    }

    /// Function to create a new payment contract.
    public fun create_contract(owner: &signer, freelancer: address, amount_due: u64) {
        let client = signer::address_of(owner);
        let contract = Contract {
            freelancer,
            client,
            amount_due,
            paid_amount: 0,
        };
        move_to(owner, contract);
    }

    /// Function to release payment to the freelancer.
    public fun pay_freelancer(payer: &signer, contract_owner: address, amount: u64) acquires Contract {
        let contract = borrow_global_mut<Contract>(contract_owner);
        let client = contract.client;

        // Ensure the client is paying the correct amount
        assert!(contract.paid_amount + amount <= contract.amount_due, 100);

        // Transfer payment from client to freelancer
        let payment = coin::withdraw<AptosCoin>(payer, amount);
        coin::deposit<AptosCoin>(contract.freelancer, payment);

        // Update the amount paid so far
        contract.paid_amount = contract.paid_amount + amount;
    }
}
