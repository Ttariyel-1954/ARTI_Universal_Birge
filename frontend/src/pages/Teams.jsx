import { useEffect, useState } from 'react';
import { Users, Phone, Briefcase } from 'lucide-react';
import { teamsApi } from '../api/teams.api';
import { Card } from '../components/ui/Card';

const typeLabels = {
  masonry:    '🧱 Dulusçu',
  plumbing:   '🔧 Santexnik',
  electrical: '⚡ Elektrik',
  painting:   '🎨 Rəngsaz',
  roofing:    '🏠 Dam ustası',
  general:    '👷 Ümumi',
};

export default function Teams() {
  const [teams, setTeams] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    teamsApi.list()
      .then(res => setTeams(res.data.data || []))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p>Yüklənir...</p>;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Users size={28} className="text-primary-600" />
        <h1 className="text-2xl font-bold">Briqadalar</h1>
        <span className="text-sm text-slate-500">({teams.length} briqada)</span>
      </div>

      {teams.length === 0 ? (
        <Card>
          <div className="text-center py-12">
            <Users size={48} className="text-slate-300 mx-auto mb-3" />
            <p className="text-slate-500 mb-2">Hələ briqada qeyd olunmayıb</p>
            <p className="text-xs text-slate-400">
              Briqadalar Dərs 2-də seed məlumatına daxil edilməyib.
              Real mühitdə layihə üçün briqadalar burada görünəcək.
            </p>
          </div>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {teams.map((team) => (
            <Card key={team.id} className="hover:shadow-md transition">
              <div className="flex items-start justify-between mb-3">
                <h3 className="font-semibold text-slate-800">{team.name}</h3>
                <span className="text-xs text-slate-500">
                  {typeLabels[team.team_type] || team.team_type || '—'}
                </span>
              </div>
              {team.project_name && (
                <p className="text-sm text-slate-600 mb-3 flex items-center gap-1">
                  <Briefcase size={14} className="text-slate-400" />
                  {team.project_code} · {team.project_name}
                </p>
              )}
              <div className="pt-3 border-t border-slate-100 space-y-2 text-sm">
                {team.leader_name && (
                  <p className="text-slate-700">
                    <span className="text-slate-500">Rəhbər:</span> {team.leader_name}
                  </p>
                )}
                {team.leader_phone && (
                  <p className="text-slate-700 flex items-center gap-1">
                    <Phone size={14} className="text-slate-400" />
                    {team.leader_phone}
                  </p>
                )}
                <div className="flex gap-4 pt-2">
                  <span className="text-xs bg-primary-50 text-primary-700 px-2 py-0.5 rounded">
                    {team.member_count || 0} üzv
                  </span>
                  <span className="text-xs bg-amber-50 text-amber-700 px-2 py-0.5 rounded">
                    {team.task_count || 0} tapşırıq
                  </span>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
