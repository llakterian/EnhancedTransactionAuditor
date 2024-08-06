import React, { useState } from 'react';
import { ethers } from 'ethers';

function TransactionRegistration({ contract }) {
    const [to, setTo] = useState('');
    const [amount, setAmount] = useState('');
    const [description, setDescription] = useState('');
    const [category, setCategory] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const tx = await contract.registerTransaction(to, ethers.utils.parseEther(amount), description, category);
            await tx.wait();
            alert('Transaction registered successfully!');
        } catch (error) {
            console.error('Error registering transaction:', error);
            alert('Failed to register transaction');
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <input type="text" value={to} onChange={(e) => setTo(e.target.value)} placeholder="To Address" required />
            <input type="text" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="Amount (ETH)" required />
            <input type="text" value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Description" required />
            <input type="text" value={category} onChange={(e) => setCategory(e.target.value)} placeholder="Category" required />
            <button type="submit">Register Transaction</button>
        </form>
    );
}

export default TransactionRegistration;