import { useState } from 'react';
import { useNavigate, Navigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import toast from 'react-hot-toast';
import { LogIn } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';

export default function Login() {
  const navigate = useNavigate();
  const { login, isAuthenticated } = useAuth();
  const [loading, setLoading] = useState(false);
  const { register, handleSubmit, formState: { errors } } = useForm();

  if (isAuthenticated) return <Navigate to="/dashboard" />;

  const onSubmit = async (data) => {
    setLoading(true);
    try {
      await login(data.email, data.password);
      toast.success('Xoş gəldiniz!');
      navigate('/dashboard');
    } catch (err) {
      toast.error(err.response?.data?.message || 'Giriş uğursuz');
    } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-slate-50 to-primary-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-8">
        <div className="text-center mb-6">
          <h1 className="text-3xl font-bold text-primary-700">🏗️ TTİS</h1>
          <p className="text-slate-600 mt-2">Daxil olun</p>
        </div>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <Input
            label="Email"
            type="email"
            placeholder="siz@arti.edu.az"
            error={errors.email?.message}
            {...register('email', { required: 'Email tələb olunur' })}
          />
          <Input
            label="Şifrə"
            type="password"
            placeholder="••••••••"
            error={errors.password?.message}
            {...register('password', { required: 'Şifrə tələb olunur', minLength: { value: 6, message: 'Minimum 6 simvol' } })}
          />
          <Button type="submit" className="w-full" loading={loading}>
            <LogIn size={18} className="mr-2" /> Daxil ol
          </Button>
        </form>
      </div>
    </div>
  );
}
