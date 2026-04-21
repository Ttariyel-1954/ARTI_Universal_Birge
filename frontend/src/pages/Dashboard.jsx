import { useEffect, useState } from 'react';
import { FolderKanban, TrendingUp, DollarSign, AlertTriangle } from 'lucide-react';
import { projectsApi } from '../api/projects.api';
import { Card } from '../components/ui/Card';
import { StatusBadge } from '../components/ui/StatusBadge';

function StatCard({ icon: Icon, title, value, color = 'primary' }) {
  const colors = {
    primary: 'bg-primary-50 text-primary-700',
    green:   'bg-green-50 text-green-700',
    amber:   'bg-amber-50 text-amber-700',
    red:     'bg-red-50 text-red-700',
  };
  return (
    <Card className="flex items-center gap-4">
      <div className={`w-12 h-12 rounded-lg flex items-center justify-center ${colors[color]}`}>
        <Icon size={24} />
      </div>
      <div>
        <p className="text-sm text-slate-500">{title}</p>
        <p className="text-2xl font-bold text-slate-800">{value}</p>
      </div>
    </Card>
  );
}

export default function Dashboard() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    projectsApi.list()
      .then(res => setProjects(res.data.data || []))
      .finally(() => setLoading(false));
  }, []);

  const stats = {
    total:   projects.length,
    active:  projects.filter(p => p.status === 'in_progress').length,
    budget:  projects.reduce((s, p) => s + parseFloat(p.total_budget_planned || 0), 0),
    overdue: projects.filter(p => p.deadline_status === 'overdue').length,
  };

  if (loading) return <p>Yüklənir...</p>;

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-slate-800">Ümumi baxış</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon={FolderKanban} title="Ümumi layihə" value={stats.total} />
        <StatCard icon={TrendingUp} title="Aktiv" value={stats.active} color="green" />
        <StatCard icon={DollarSign} title="Büdcə (AZN)" value={stats.budget.toLocaleString()} color="amber" />
        <StatCard icon={AlertTriangle} title="Gecikir" value={stats.overdue} color="red" />
      </div>
      <Card>
        <h2 className="text-lg font-semibold mb-4">Son layihələr</h2>
        {projects.length === 0 ? (
          <p className="text-slate-500">Hələ layihə yoxdur</p>
        ) : (
          <div className="space-y-3">
            {projects.slice(0, 5).map((p) => (
              <div key={p.id} className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                <div>
                  <p className="font-medium">{p.project_name}</p>
                  <p className="text-sm text-slate-500">{p.region} · {p.project_code}</p>
                </div>
                <StatusBadge status={p.status} />
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
}
