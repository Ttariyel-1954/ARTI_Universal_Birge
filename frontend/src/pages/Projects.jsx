import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Eye } from 'lucide-react';
import { projectsApi } from '../api/projects.api';
import { Card } from '../components/ui/Card';
import { StatusBadge } from '../components/ui/StatusBadge';

export default function Projects() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    projectsApi.list()
      .then(res => setProjects(res.data.data || []))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Layihələr</h1>
      <Card>
        {loading ? <p>Yüklənir...</p> : (
          <table className="w-full">
            <thead>
              <tr className="text-left text-xs text-slate-500 uppercase border-b">
                <th className="py-2 pr-4">Kod</th>
                <th>Layihə</th>
                <th>Region</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {projects.map((p) => (
                <tr key={p.id} className="border-b hover:bg-slate-50">
                  <td className="py-3 pr-4 font-mono text-sm text-primary-700">{p.project_code}</td>
                  <td className="py-3 pr-4">{p.project_name}</td>
                  <td className="text-sm">{p.region}</td>
                  <td><StatusBadge status={p.status} /></td>
                  <td>
                    <Link to={`/projects/${p.id}`} className="text-primary-600 hover:text-primary-800">
                      <Eye size={18} />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  );
}
