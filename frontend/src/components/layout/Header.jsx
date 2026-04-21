import { useAuth } from '../../hooks/useAuth';
import { LogOut, Bell, User } from 'lucide-react';

export function Header() {
  const { user, logout } = useAuth();
  return (
    <header className="bg-white border-b border-slate-200 px-6 py-3 flex items-center justify-between">
      <h2 className="text-lg font-semibold text-slate-800">Xoş gördük, {user?.full_name} 👋</h2>
      <div className="flex items-center gap-4">
        <button className="text-slate-500 hover:text-slate-800"><Bell size={20} /></button>
        <div className="flex items-center gap-2 px-3 py-1.5 bg-slate-100 rounded-lg">
          <User size={16} className="text-slate-500" />
          <span className="text-sm text-slate-700">{user?.role_code}</span>
        </div>
        <button onClick={logout} className="flex items-center gap-2 px-3 py-1.5 text-red-600 hover:bg-red-50 rounded-lg transition">
          <LogOut size={16} /> Çıxış
        </button>
      </div>
    </header>
  );
}
