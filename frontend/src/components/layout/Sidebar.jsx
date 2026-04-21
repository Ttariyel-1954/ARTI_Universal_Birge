import { NavLink } from 'react-router-dom';
import { LayoutDashboard, FolderKanban, Building2, Users, Settings } from 'lucide-react';
import clsx from 'clsx';

const navItems = [
  { to: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/projects',  label: 'Layihələr', icon: FolderKanban },
  { to: '/objects',   label: 'Obyektlər', icon: Building2 },
  { to: '/teams',     label: 'Briqadalar', icon: Users },
  { to: '/settings',  label: 'Parametrlər', icon: Settings },
];

export function Sidebar() {
  return (
    <aside className="w-64 bg-slate-900 text-white flex flex-col">
      <div className="p-6 border-b border-slate-800">
        <h1 className="text-2xl font-bold">🏗️ <span className="text-primary-400">TTİS</span></h1>
        <p className="text-xs text-slate-400 mt-1">Təmir-Tikinti İdarəsi</p>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) => clsx(
                'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors',
                isActive ? 'bg-primary-600 text-white' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
              )}
            >
              <Icon size={18} /> {item.label}
            </NavLink>
          );
        })}
      </nav>
      <div className="p-4 border-t border-slate-800 text-xs text-slate-500">v0.1.0 — ARTI</div>
    </aside>
  );
}
