import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, Sparkles } from 'lucide-react';
import toast from 'react-hot-toast';
import { projectsApi } from '../api/projects.api';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { StatusBadge } from '../components/ui/StatusBadge';

export default function ProjectDetail() {
  const { id } = useParams();
  const [project, setProject] = useState(null);
  const [analysis, setAnalysis] = useState(null);
  const [analyzing, setAnalyzing] = useState(false);

  useEffect(() => {
    projectsApi.get(id).then(res => setProject(res.data.data));
  }, [id]);

  const handleAnalyze = async () => {
    setAnalyzing(true);
    try {
      const res = await projectsApi.analyze(id);
      setAnalysis(res.data.analysis);
      toast.success('AI təhlil hazırdır!');
    } catch { toast.error('AI təhlil alınmadı'); }
    finally { setAnalyzing(false); }
  };

  if (!project) return <p>Yüklənir...</p>;

  return (
    <div className="space-y-6">
      <Link to="/projects" className="inline-flex items-center gap-2 text-slate-600 hover:text-primary-600">
        <ArrowLeft size={16} /> Layihələrə qayıt
      </Link>
      <Card>
        <div className="flex items-start justify-between mb-4">
          <div>
            <p className="font-mono text-sm text-primary-700">{project.project_code}</p>
            <h1 className="text-2xl font-bold mt-1">{project.project_name}</h1>
          </div>
          <StatusBadge status={project.status} />
        </div>
      </Card>
      <Card>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold flex items-center gap-2">
            <Sparkles size={20} className="text-purple-600" /> Claude AI təhlil
          </h2>
          <Button onClick={handleAnalyze} loading={analyzing}>
            {analysis ? 'Yenidən təhlil et' : 'Təhlil et'}
          </Button>
        </div>
        {analysis ? (
          <div className="whitespace-pre-wrap text-slate-700">{analysis}</div>
        ) : (
          <p className="text-slate-500 text-sm">"Təhlil et" düyməsini basın.</p>
        )}
      </Card>
    </div>
  );
}
