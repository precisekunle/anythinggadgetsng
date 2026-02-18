export const PaymentService = {
    initiatePayment: async (amount: number, email: string) => {
        console.log(`Initiating payment for ${amount} for ${email}`);

        // Mock Paystack pop-up
        return new Promise((resolve) => {
            const confirmed = window.confirm(`Pay ₦${amount.toLocaleString()} with Paystack?`);
            resolve(confirmed);
        });
    }
};
