export interface UserSettingsDialogLayout {
  dialogRadius: number;
  dialogPadding: number;
  titleFontSize: number;
  sectionTitleFontSize: number;
  sectionTitleLetterSpacing: number;
  sectionGap: number;
  subsectionGap: number;
  languageOptionPaddingX: number;
  languageOptionPaddingY: number;
  languageOptionRadius: number;
  languageCheckIconSize: number;
  appearancePaddingX: number;
  appearancePaddingY: number;
  appearanceRadius: number;
  teamCardPadding: number;
  teamCardRadius: number;
  teamLogoWidth: number;
  teamLogoHeight: number;
  teamLogoPadding: number;
  teamLogoRadius: number;
  teamRowGap: number;
}

interface RenderNode {
  id: string;
  props?: Record<string, unknown>;
  children?: RenderNode[];
}

interface UserSettingsRenderPlan {
  surfaceId: string;
  roots: RenderNode[];
}

export const DEFAULT_USER_SETTINGS_LAYOUT: UserSettingsDialogLayout = {
  dialogRadius: 20,
  dialogPadding: 24,
  titleFontSize: 24,
  sectionTitleFontSize: 14,
  sectionTitleLetterSpacing: 1.2,
  sectionGap: 24,
  subsectionGap: 12,
  languageOptionPaddingX: 16,
  languageOptionPaddingY: 12,
  languageOptionRadius: 12,
  languageCheckIconSize: 20,
  appearancePaddingX: 16,
  appearancePaddingY: 8,
  appearanceRadius: 16,
  teamCardPadding: 12,
  teamCardRadius: 16,
  teamLogoWidth: 48,
  teamLogoHeight: 48,
  teamLogoPadding: 8,
  teamLogoRadius: 12,
  teamRowGap: 16,
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

function extractLayout(plan: UserSettingsRenderPlan): UserSettingsDialogLayout | null {
  if (plan.surfaceId !== 'os_shell/user_settings_dialog') return null;
  if (!Array.isArray(plan.roots) || plan.roots.length === 0) return null;

  const nodeMap = new Map<string, RenderNode>();
  collectNodes(plan.roots, nodeMap);

  const root = nodeMap.get('settings_dialog_root');
  const sections = nodeMap.get('settings_sections');
  const title = nodeMap.get('settings_title');
  const language = nodeMap.get('language_section');
  const appearance = nodeMap.get('appearance_section');
  const team = nodeMap.get('team_section');

  if (!root || !sections || !title || !language || !appearance || !team) {
    return null;
  }

  const dialogRadius = toNumber(root.props?.borderRadius);
  const dialogPadding = toNumber(root.props?.padding);
  const titleFontSize = toNumber(title.props?.fontSize);
  const sectionTitleFontSize = toNumber(language.props?.sectionTitleFontSize);
  const sectionTitleLetterSpacing = toNumber(language.props?.sectionTitleLetterSpacing);
  const sectionGap = toNumber(sections.props?.sectionGap);
  const subsectionGap = toNumber(sections.props?.subsectionGap);
  const languageOptionPaddingX = toNumber(language.props?.optionPaddingX);
  const languageOptionPaddingY = toNumber(language.props?.optionPaddingY);
  const languageOptionRadius = toNumber(language.props?.optionRadius);
  const languageCheckIconSize = toNumber(language.props?.checkIconSize);
  const appearancePaddingX = toNumber(appearance.props?.paddingX);
  const appearancePaddingY = toNumber(appearance.props?.paddingY);
  const appearanceRadius = toNumber(appearance.props?.radius);
  const teamCardPadding = toNumber(team.props?.cardPadding);
  const teamCardRadius = toNumber(team.props?.cardRadius);
  const teamLogoWidth = toNumber(team.props?.logoWidth);
  const teamLogoHeight = toNumber(team.props?.logoHeight);
  const teamLogoPadding = toNumber(team.props?.logoPadding);
  const teamLogoRadius = toNumber(team.props?.logoRadius);
  const teamRowGap = toNumber(team.props?.rowGap);

  if (
    dialogRadius == null ||
    dialogPadding == null ||
    titleFontSize == null ||
    sectionTitleFontSize == null ||
    sectionTitleLetterSpacing == null ||
    sectionGap == null ||
    subsectionGap == null ||
    languageOptionPaddingX == null ||
    languageOptionPaddingY == null ||
    languageOptionRadius == null ||
    languageCheckIconSize == null ||
    appearancePaddingX == null ||
    appearancePaddingY == null ||
    appearanceRadius == null ||
    teamCardPadding == null ||
    teamCardRadius == null ||
    teamLogoWidth == null ||
    teamLogoHeight == null ||
    teamLogoPadding == null ||
    teamLogoRadius == null ||
    teamRowGap == null
  ) {
    return null;
  }

  return {
    dialogRadius,
    dialogPadding,
    titleFontSize,
    sectionTitleFontSize,
    sectionTitleLetterSpacing,
    sectionGap,
    subsectionGap,
    languageOptionPaddingX,
    languageOptionPaddingY,
    languageOptionRadius,
    languageCheckIconSize,
    appearancePaddingX,
    appearancePaddingY,
    appearanceRadius,
    teamCardPadding,
    teamCardRadius,
    teamLogoWidth,
    teamLogoHeight,
    teamLogoPadding,
    teamLogoRadius,
    teamRowGap,
  };
}

export async function loadUserSettingsLayout(signal?: AbortSignal): Promise<UserSettingsDialogLayout> {
  try {
    const response = await fetch('/parity/os_shell_user_settings_dialog.parity.render.json', {
      signal,
      cache: 'no-store',
    });
    if (!response.ok) return DEFAULT_USER_SETTINGS_LAYOUT;
    const plan = (await response.json()) as UserSettingsRenderPlan;
    return extractLayout(plan) ?? DEFAULT_USER_SETTINGS_LAYOUT;
  } catch {
    return DEFAULT_USER_SETTINGS_LAYOUT;
  }
}
