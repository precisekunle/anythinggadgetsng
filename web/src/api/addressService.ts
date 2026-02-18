import { supabase } from '../supabaseClient';
import { UserAddress } from '../types/user_address';

export const AddressService = {
    getAddresses: async (userId: string): Promise<UserAddress[]> => {
        const { data, error } = await supabase
            .from('addresses')
            .select('*')
            .eq('user_id', userId)
            .order('is_default', { ascending: false })
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data || [];
    },

    addAddress: async (address: Omit<UserAddress, 'id' | 'created_at'>): Promise<void> => {
        const { error } = await supabase
            .from('addresses')
            .insert(address);

        if (error) throw error;
    },

    updateAddress: async (address: UserAddress): Promise<void> => {
        const { error } = await supabase
            .from('addresses')
            .update(address)
            .eq('id', address.id);

        if (error) throw error;
    },

    deleteAddress: async (addressId: string): Promise<void> => {
        const { error } = await supabase
            .from('addresses')
            .delete()
            .eq('id', addressId);

        if (error) throw error;
    },

    setDefaultAddress: async (userId: string, addressId: string): Promise<void> => {
        // Reset defaults
        const { error: resetError } = await supabase
            .from('addresses')
            .update({ is_default: false })
            .eq('user_id', userId);

        if (resetError) throw resetError;

        // Set new default
        const { error: setError } = await supabase
            .from('addresses')
            .update({ is_default: true })
            .eq('id', addressId);

        if (setError) throw setError;
    }
};
