import React, { useEffect, useMemo, useState } from 'react';
import { BUILTIN_INTENT_HANDLERS, type IntentHandler } from './intent-handlers/builtin';

interface RenderNode {
  id: string;
  type: string;
  component: string;
  props?: Record<string, unknown>;
  children?: RenderNode[];
}

interface RenderPlan {
  schemaVersion: string;
  surfaceId: string;
  states?: string[];
  roots: RenderNode[];
}

interface AutoParitySurfaceProps {
  surfaceId: string;
  parityAssetPath: string;
  handlers?: Record<string, IntentHandler>;
  className?: string;
}

function toPx(value: unknown): string | undefined {
  if (typeof value === 'number' && Number.isFinite(value)) return `${value}px`;
  return undefined;
}

function resolveAssetPath(value: unknown): string | undefined {
  if (typeof value !== 'string') return undefined;
  if (value.startsWith('/')) return value;
  if (value.startsWith('assets/icons/')) return `/icons/${value.slice('assets/icons/'.length)}`;
  if (value.startsWith('assets/logos/')) return `/icons/${value.slice('assets/logos/'.length)}`;
  return `/${value}`;
}

function intentIdFromProps(nodeId: string, props?: Record<string, unknown>): string | null {
  if (!props) return null;
  const candidates = [
    props.intentId,
    props.intent,
    props.actionIntent,
    props.navIntent,
    props.control,
    props.role,
  ];
  for (const candidate of candidates) {
    if (typeof candidate !== 'string') continue;
    const id = candidate.trim().toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '');
    if (id) return id;
  }
  if (nodeId.includes('button') || nodeId.includes('action')) return nodeId;
  return null;
}

function styleFromProps(props?: Record<string, unknown>): React.CSSProperties | undefined {
  if (!props) return undefined;
  const style: React.CSSProperties = {
    borderRadius: toPx(props.borderRadius ?? props.radius),
    width: toPx(props.width),
    height: toPx(props.height),
    padding: toPx(props.padding),
    top: toPx(props.topOffset),
    marginLeft: toPx(props.marginX),
    marginRight: toPx(props.marginX),
    marginTop: toPx(props.marginY),
    marginBottom: toPx(props.marginY),
  };

  if (typeof props.paddingX === 'number' || typeof props.paddingY === 'number') {
    const py = typeof props.paddingY === 'number' ? `${props.paddingY}px` : '0px';
    const px = typeof props.paddingX === 'number' ? `${props.paddingX}px` : '0px';
    style.padding = `${py} ${px}`;
  }

  if (typeof props.sectionGap === 'number') {
    style.gap = `${props.sectionGap}px`;
  }

  Object.keys(style).forEach((key) => {
    const typedKey = key as keyof React.CSSProperties;
    if (style[typedKey] == null) {
      delete style[typedKey];
    }
  });

  return Object.keys(style).length > 0 ? style : undefined;
}

function textFromNode(node: RenderNode): string {
  const props = node.props || {};
  if (typeof props.text === 'string') return props.text;
  if (typeof props.sectionTitle === 'string') return props.sectionTitle;
  if (typeof props.role === 'string') return props.role;
  return node.id;
}

function imageSourceFromNode(node: RenderNode): string | undefined {
  const props = node.props || {};
  return (
    resolveAssetPath(props.asset) ||
    resolveAssetPath(props.iconAsset) ||
    resolveAssetPath(props.logoFallbackAsset) ||
    resolveAssetPath(props.fallbackAsset)
  );
}

function mapTag(node: RenderNode): keyof JSX.IntrinsicElements {
  if (node.type === 'button') return 'button';
  if (node.type === 'text') return 'span';
  if (node.type === 'image') return 'img';
  if (node.type === 'header') return 'header';
  if (node.type === 'row') return 'div';
  if (node.type === 'column') return 'div';
  if (node.type === 'card') return 'article';
  return 'div';
}

export default function AutoParitySurface({
  surfaceId,
  parityAssetPath,
  handlers,
  className,
}: AutoParitySurfaceProps) {
  const [plan, setPlan] = useState<RenderPlan | null>(null);
  const mergedHandlers = useMemo(() => ({ ...BUILTIN_INTENT_HANDLERS, ...(handlers || {}) }), [handlers]);

  useEffect(() => {
    const controller = new AbortController();
    (async () => {
      try {
        const response = await fetch(parityAssetPath, { signal: controller.signal, cache: 'no-store' });
        if (!response.ok) return;
        const json = (await response.json()) as RenderPlan;
        setPlan(json);
      } catch {
        // Ignore fetch failures; component renders fallback.
      }
    })();

    return () => controller.abort();
  }, [parityAssetPath]);

  function renderNode(node: RenderNode): React.ReactNode {
    const Tag = mapTag(node);
    const props = node.props || {};
    const intentId = intentIdFromProps(node.id, props);
    const onClick = intentId ? mergedHandlers[intentId] : undefined;

    if (Tag === 'img') {
      const src = imageSourceFromNode(node);
      return (
        <img
          key={node.id}
          data-parity-node={node.id}
          data-parity-type={node.type}
          className={`parity-node parity-node-${node.type}`}
          src={src}
          alt={node.id}
          style={styleFromProps(props)}
        />
      );
    }

    return (
      <Tag
        key={node.id}
        data-parity-node={node.id}
        data-parity-type={node.type}
        className={`parity-node parity-node-${node.type}`}
        onClick={onClick}
        style={styleFromProps(props)}
      >
        {node.type === 'text' ? textFromNode(node) : null}
        {Array.isArray(node.children) ? node.children.map((child) => renderNode(child)) : null}
      </Tag>
    );
  }

  if (!plan || !Array.isArray(plan.roots) || plan.roots.length === 0) {
    return (
      <section className={className} data-parity-surface={surfaceId}>
        <p>Loading parity surface...</p>
      </section>
    );
  }

  return (
    <section className={className} data-parity-surface={surfaceId}>
      {plan.roots.map((root) => renderNode(root))}
    </section>
  );
}
