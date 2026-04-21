import { Settings as SettingsIcon, User, Shield, Database, Info } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { Card } from '../components/ui/Card';

export default function Settings() {
  const { user } = useAuth();

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <SettingsIcon size={28} className="text-primary-600" />
        <h1 className="text-2xl font-bold">Parametrlər</h1>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Profil */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <User size={20} className="text-primary-600" />
            <h2 className="font-semibold">Profil</h2>
          </div>
          <div className="space-y-3 text-sm">
            <div>
              <p className="text-slate-500">Ad, soyad</p>
              <p className="font-medium">{user?.full_name || '—'}</p>
            </div>
            <div>
              <p className="text-slate-500">Email</p>
              <p className="font-medium">{user?.email || '—'}</p>
            </div>
            <div>
              <p className="text-slate-500">Rol</p>
              <p className="font-medium">{user?.role_code || '—'}</p>
            </div>
            <div>
              <p className="text-slate-500">ID</p>
              <p className="font-mono text-xs text-slate-400">#{user?.id}</p>
            </div>
          </div>
        </Card>

        {/* Təhlükəsizlik */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <Shield size={20} className="text-green-600" />
            <h2 className="font-semibold">Təhlükəsizlik</h2>
          </div>
          <div className="space-y-3 text-sm">
            <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
              <span className="text-green-700">JWT aktiv sessiya</span>
              <span className="text-xs bg-green-200 text-green-800 px-2 py-0.5 rounded-full">✓</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
              <span className="text-slate-600">bcrypt parol şifrələməsi</span>
              <span className="text-xs bg-slate-200 text-slate-700 px-2 py-0.5 rounded-full">10 rounds</span>
            </div>
            <p className="text-xs text-slate-500 mt-2">
              Parol dəyişmək funksiyası növbəti versiyada əlavə olunacaq.
            </p>
          </div>
        </Card>

        {/* Sistem */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <Database size={20} className="text-amber-600" />
            <h2 className="font-semibold">Sistem</h2>
          </div>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-slate-500">Frontend</span>
              <span className="font-mono">React 19 + Vite 6</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">Backend</span>
              <span className="font-mono">Node.js + Express</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">DB</span>
              <span className="font-mono">PostgreSQL 18</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">AI</span>
              <span className="font-mono">Claude Sonnet 4.6</span>
            </div>
          </div>
        </Card>

        {/* Haqqında */}
        <Card>
          <div className="flex items-center gap-2 mb-4">
            <Info size={20} className="text-purple-600" />
            <h2 className="font-semibold">Haqqında</h2>
          </div>
          <div className="space-y-2 text-sm text-slate-600">
            <p><strong>TTİS</strong> — Təmir-Tikinti İdarəetmə Sistemi</p>
            <p>Versiya: <span className="font-mono">v0.1.0</span></p>
            <p>Təşkilat: <strong>ARTI</strong></p>
            <p className="pt-2 border-t border-slate-100 text-xs text-slate-400">
              Azərbaycan təhsil obyektlərinin təmir-tikinti proseslərini
              idarəetmək üçün AI-əsaslı sistem.
            </p>
          </div>
        </Card>
      </div>
    </div>
  );
}
