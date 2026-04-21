import { useEffect, useState } from 'react';
import { Building2, MapPin } from 'lucide-react';
import { objectsApi } from '../api/objects.api';
import { Card } from '../components/ui/Card';

const conditionConfig = {
  excellent:    { label: 'Əla',         cls: 'bg-green-100 text-green-700' },
  good:         { label: 'Yaxşı',       cls: 'bg-blue-100 text-blue-700' },
  satisfactory: { label: 'Qənaətbəxş',  cls: 'bg-amber-100 text-amber-700' },
  poor:         { label: 'Pis',         cls: 'bg-orange-100 text-orange-700' },
  emergency:    { label: 'Təcili',      cls: 'bg-red-100 text-red-700' },
};

function ConditionBadge({ condition }) {
  const c = conditionConfig[condition] || { label: condition || '—', cls: 'bg-slate-100 text-slate-600' };
  return <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-medium ${c.cls}`}>{c.label}</span>;
}

export default function Objects() {
  const [objects, setObjects] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    objectsApi.list()
      .then(res => setObjects(res.data.data || []))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p>Yüklənir...</p>;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Building2 size={28} className="text-primary-600" />
        <h1 className="text-2xl font-bold">Obyektlər</h1>
        <span className="text-sm text-slate-500">({objects.length} obyekt)</span>
      </div>

      {objects.length === 0 ? (
        <Card>
          <p className="text-slate-500 text-center py-8">Hələ obyekt yoxdur</p>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {objects.map((obj) => (
            <Card key={obj.id} className="hover:shadow-md transition">
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-2">
                  <span className="text-2xl">{obj.icon || '🏢'}</span>
                  <span className="text-xs text-slate-500 font-mono">{obj.code}</span>
                </div>
                <ConditionBadge condition={obj.technical_condition} />
              </div>
              <h3 className="font-semibold text-slate-800 mb-1">{obj.name}</h3>
              <p className="text-sm text-slate-600 mb-3 flex items-start gap-1">
                <MapPin size={14} className="text-slate-400 mt-0.5 flex-shrink-0" />
                <span>{obj.region} · {obj.object_type}</span>
              </p>
              <div className="pt-3 border-t border-slate-100 grid grid-cols-3 gap-2 text-xs">
                <div>
                  <p className="text-slate-500">Sahə</p>
                  <p className="font-semibold">{obj.area_sqm ? `${obj.area_sqm} m²` : '—'}</p>
                </div>
                <div>
                  <p className="text-slate-500">Mərtəbə</p>
                  <p className="font-semibold">{obj.total_floors || '—'}</p>
                </div>
                <div>
                  <p className="text-slate-500">Tikilib</p>
                  <p className="font-semibold">{obj.year_built || '—'}</p>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
