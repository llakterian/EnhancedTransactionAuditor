import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import EnhancedTransactionAuditor from './contracts/EnhancedTransactionAuditor.json';

function App() {
    const [contract, setContract] = useState(null);
    const [transactions, setTransactions] = useState([]);

    useEffect(() => {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contractInstance = new ethers.Contract(CONTRACT_ADDRESS, EnhancedTransactionAuditor.abi, signer);
        setContract(contractInstance);

        contractInstance.on("TransactionRegistered", (id, from, to, amount, category) => {
            setTransactions(prev => [...prev, { id, from, to, amount, category }]);
        });

        return () => {
            contractInstance.removeAllListeners();
        };
    }, []);

    // Render your components here
}

export default App;

