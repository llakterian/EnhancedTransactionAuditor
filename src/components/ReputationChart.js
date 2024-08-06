import React from 'react';
import { Bar } from 'react-chartjs-2';

function ReputationChart({ userReputation, auditorReputation }) {
    const data = {
        labels: ['User Reputation', 'Auditor Reputation'],
        datasets: [
            {
                label: 'Reputation Scores',
                data: [userReputation, auditorReputation],
                backgroundColor: ['rgba(75, 192, 192, 0.6)', 'rgba(153, 102, 255, 0.6)'],
            },
        ],
    };

    return <Bar data={data} />;
}

export default ReputationChart;
