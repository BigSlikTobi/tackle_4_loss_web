export interface FloatingNavLayout {
  navHeight: number;
  navMarginX: number;
  navMarginY: number;
  navButtonSize: number;
  navIconSize: number;
  centerSpacerWidth: number;
  centerButtonTop: number;
  centerButtonWidth: number;
  centerButtonHeight: number;
  centerButtonPadding: number;
  centerButtonBorderWidth: number;
}

interface RenderNode {
  id: string;
  component: string;
  props?: Record<string, unknown>;
  children?: RenderNode[];
}

interface FloatingNavRenderPlan {
  schemaVersion: string;
  surfaceId: string;
  roots: RenderNode[];
}

export const DEFAULT_FLOATING_NAV_LAYOUT: FloatingNavLayout = {
  navHeight: 64,
  navMarginX: 24,
  navMarginY: 24,
  navButtonSize: 48,
  navIconSize: 24,
  centerSpacerWidth: 60,
  centerButtonTop: -24,
  centerButtonWidth: 64,
  centerButtonHeight: 64,
  centerButtonPadding: 4,
  centerButtonBorderWidth: 3,
};

function toNumber(value: unknown): number | null {
  if (typeof value === 'number' && Number.isFinite(value)) return value;
  return null;
}

function collectNodes(nodes: RenderNode[], map: Map<string, RenderNode>) {
  for (const node of nodes) {
    map.set(node.id, node);
    if (Array.isArray(node.children) && node.children.length > 0) {
      collectNodes(node.children, map);
    }
  }
}

function extractLayoutFromPlan(plan: FloatingNavRenderPlan): FloatingNavLayout | null {
  if (plan.surfaceId !== 'os_shell/floating_nav') return null;
  if (!Array.isArray(plan.roots) || plan.roots.length === 0) return null;

  const nodeMap = new Map<string, RenderNode>();
  collectNodes(plan.roots, nodeMap);

  const root = nodeMap.get('floating_nav_root');
  const centerSpacer = nodeMap.get('center_spacer');
  const centerButton = nodeMap.get('center_team_button');
  const homeButton = nodeMap.get('home_button');

  if (!root || !centerSpacer || !centerButton || !homeButton) {
    return null;
  }

  const navHeight = toNumber(root.props?.height);
  const navMarginX = toNumber(root.props?.marginX);
  const navMarginY = toNumber(root.props?.marginY);
  const navButtonSize = toNumber(homeButton.props?.size);
  const navIconSize = toNumber(homeButton.props?.iconSize);
  const centerSpacerWidth = toNumber(centerSpacer.props?.width);
  const centerButtonTop = toNumber(centerButton.props?.topOffset);
  const centerButtonWidth = toNumber(centerButton.props?.width);
  const centerButtonHeight = toNumber(centerButton.props?.height);
  const centerButtonPadding = toNumber(centerButton.props?.padding);
  const centerButtonBorderWidth = toNumber(centerButton.props?.borderWidth);

  if (
    navHeight == null ||
    navMarginX == null ||
    navMarginY == null ||
    navButtonSize == null ||
    navIconSize == null ||
    centerSpacerWidth == null ||
    centerButtonTop == null ||
    centerButtonWidth == null ||
    centerButtonHeight == null ||
    centerButtonPadding == null ||
    centerButtonBorderWidth == null
  ) {
    return null;
  }

  return {
    navHeight,
    navMarginX,
    navMarginY,
    navButtonSize,
    navIconSize,
    centerSpacerWidth,
    centerButtonTop,
    centerButtonWidth,
    centerButtonHeight,
    centerButtonPadding,
    centerButtonBorderWidth,
  };
}

export async function loadFloatingNavLayout(signal?: AbortSignal): Promise<FloatingNavLayout> {
  try {
    const response = await fetch('/parity/os_shell_floating_nav.parity.render.json', {
      signal,
      cache: 'no-store',
    });
    if (!response.ok) {
      return DEFAULT_FLOATING_NAV_LAYOUT;
    }

    const plan = (await response.json()) as FloatingNavRenderPlan;
    const layout = extractLayoutFromPlan(plan);
    return layout ?? DEFAULT_FLOATING_NAV_LAYOUT;
  } catch {
    return DEFAULT_FLOATING_NAV_LAYOUT;
  }
}

